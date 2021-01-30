/// Copyright (c) 2021 Razeware LLC
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
import Fluent

struct UsersController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let usersRoute = routes.grouped("api", "users")
    usersRoute.get(use: getAllHandler)
    usersRoute.get(":userID", use: getHandler)
    usersRoute.get(":userID", "acronyms", use: getAcronymsHandler)
    usersRoute.get("mostRecentAcronym", use: getUserWithMostRecentAcronym)

    let basicAuthMiddleware = User.authenticator()
    let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
    basicAuthGroup.post("login", use: loginHandler)

    let tokenAuthMiddleware = Token.authenticator()
    let guardAuthMiddleware = User.guardMiddleware()
    let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    tokenAuthGroup.post(use: createHandler)
    tokenAuthGroup.delete(":userID", use: deleteHandler)
    tokenAuthGroup.post(":userID", "restore", use: restoreHandler)
    tokenAuthGroup.delete(":userID", "force", use: forceDeleteHandler)
  }

  func createHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
    let user = try req.content.decode(User.self)
    user.password = try Bcrypt.hash(user.password)
    return user.save(on: req.db).map { user.convertToPublic() }
  }

  func getAllHandler(_ req: Request) -> EventLoopFuture<[User.Public]> {
    User.query(on: req.db).all().convertToPublic()
  }

  func getHandler(_ req: Request) -> EventLoopFuture<User.Public> {
    User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).convertToPublic()
  }

  func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
    User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { user in
      user.$acronyms.get(on: req.db)
    }
  }

  func loginHandler(_ req: Request) throws -> EventLoopFuture<Token> {
    let user = try req.auth.require(User.self)
    let token = try Token.generate(for: user)
    return token.save(on: req.db).map { token }
  }

  func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
    let requestUser = try req.auth.require(User.self)
    guard requestUser.userType == .admin else {
      throw Abort(.forbidden)
    }
    return User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { user in
      user.delete(on: req.db).transform(to: .noContent)
    }
  }

  func restoreHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
    let userID = try req.parameters.require("userID", as: UUID.self)
    return User.query(on: req.db).withDeleted().filter(\.$id == userID).first().unwrap(or: Abort(.notFound)).flatMap { user in
      user.restore(on: req.db).transform(to: .ok)
    }
  }

  func forceDeleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
    User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { user in
      user.delete(force: true, on: req.db).transform(to: .noContent)
    }
  }

  func getUserWithMostRecentAcronym(_ req: Request) -> EventLoopFuture<User.Public> {
    User.query(on: req.db)
      .join(Acronym.self, on: \Acronym.$user.$id == \User.$id)
      .sort(Acronym.self, \Acronym.$createdAt, .descending)
      .first()
      .unwrap(or: Abort(.internalServerError))
      .convertToPublic()
  }
}
