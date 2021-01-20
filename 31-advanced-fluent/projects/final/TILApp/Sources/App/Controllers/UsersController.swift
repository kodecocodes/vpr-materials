/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Vapor
import Crypto
import Fluent

struct UsersController: RouteCollection {
  func boot(router: Router) throws {
    let usersRoute = router.grouped("api", "users")
    usersRoute.get(use: getAllHandler)
    usersRoute.get(User.parameter, use: getHandler)
    usersRoute.get(User.parameter, "acronyms", use: getAcronymsHandler)
    usersRoute.get("acronyms", use: getAllUsersWithAcronyms)

    let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
    let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
    basicAuthGroup.post("login", use: loginHandler)

    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    tokenAuthGroup.post(User.self, use: createHandler)
    tokenAuthGroup.delete(User.parameter, use: deleteHandler)
    tokenAuthGroup.post(UUID.parameter, "restore", use: restoreHandler)
    tokenAuthGroup.delete(User.parameter, "force", use: forceDeleteHandler)
  }

  func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
    user.password = try BCrypt.hash(user.password)
    return user.save(on: req).convertToPublic()
  }

  func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
    return User.query(on: req).decode(data: User.Public.self).all()
  }

  func getHandler(_ req: Request) throws -> Future<User.Public> {
    return try req.parameters.next(User.self).convertToPublic()
  }

  func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
    return try req.parameters.next(User.self).flatMap(to: [Acronym].self) { user in
      try user.acronyms.query(on: req).all()
    }
  }

  func loginHandler(_ req: Request) throws -> Future<Token> {
    let user = try req.requireAuthenticated(User.self)
    let token = try Token.generate(for: user)
    return token.save(on: req)
  }

  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    let requestUser = try req.requireAuthenticated(User.self)
    guard requestUser.userType == .admin else {
      throw Abort(.forbidden)
    }

    return try req.parameters.next(User.self)
      .delete(on: req)
      .transform(to: .noContent)
  }

  func restoreHandler(_ req: Request) throws -> Future<HTTPStatus> {
    let requestUser = try req.requireAuthenticated(User.self)
    guard requestUser.userType == .admin else {
      throw Abort(.forbidden)
    }

    let userID = try req.parameters.next(UUID.self)
    return User.query(on: req, withSoftDeleted: true)
      .filter(\.id == userID)
      .first()
      .flatMap(to: HTTPStatus.self) { user in
        guard let user = user else {
          throw Abort(.notFound)
        }
        return user.restore(on: req).transform(to: .ok)
    }
  }

  func forceDeleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    let requestUser = try req.requireAuthenticated(User.self)
    guard requestUser.userType == .admin else {
      throw Abort(.forbidden)
    }

    return try req.parameters.next(User.self).flatMap(to: HTTPStatus.self) { user in
      user.delete(force: true, on: req).transform(to: .noContent)
    }
  }

  func getAllUsersWithAcronyms(_ req: Request) throws -> Future<[UserWithAcronyms]> {
    return User.query(on: req).all().flatMap(to: [UserWithAcronyms].self) { users in
      try users.map { user in
        try user.acronyms.query(on: req).all().map { acronyms in
          UserWithAcronyms(id: user.id, name: user.name, username: user.username, acronyms: acronyms)
        }
        }.flatten(on: req)
    }
  }
}

struct UserWithAcronyms: Content {
  let id: UUID?
  let name: String
  let username: String
  let acronyms: [Acronym]
}
