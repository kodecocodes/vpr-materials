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
import Redis
import Fluent

struct AuthController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let authGroup = routes.grouped("auth")
    // 2
    let basicMiddleware = User.authenticator()
    // 3
    let basicAuthGroup = authGroup.grouped(basicMiddleware)
    // 4
    basicAuthGroup.post("login", use: loginHandler)
    authGroup.post("authenticate", use: authenticate)
  }

  func loginHandler(_ req: Request)
    throws -> EventLoopFuture<Token> {
      // 1
      let user = try req.auth.require(User.self)
      // 2
      let token = try Token.generate(for: user)
      // 3
      return req.redis
        .set(RedisKey(token.tokenString), toJSON: token)
        .transform(to: token)
  }

  func authenticate(_ req: Request)
    throws -> EventLoopFuture<User.Public> {
      // 1
      let data = try req.content.decode(AuthenticateData.self)
      // 2
      return req.redis
        .get(RedisKey(data.token), asJSON: Token.self)
        .flatMap { token in
        // 3
        guard let token = token else {
          return req.eventLoop.future(error: Abort(.unauthorized))
        }
        // 4
        return User.query(on: req.db)
          .filter(\.$id == token.userID)
          .first()
          .unwrap(or: Abort(.internalServerError))
          .convertToPublic()
      }
  }
}


struct AuthenticateData: Content {
  let token: String
}
