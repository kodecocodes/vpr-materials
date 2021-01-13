import Vapor

struct UserAuthMiddleware: Middleware {
  // 1
  func respond(to request: Request, chainingTo next: Responder)
    -> EventLoopFuture<Response> {
      // 2
      guard let token =
        request.headers.bearerAuthorization else {
          return request.eventLoop
            .future(error: Abort(.unauthorized))
      }
      // 3
      return request.client.post(
        "http://localhost:8081/auth/authenticate",
        beforeSend: { authRequest in
          // 4
          try authRequest.content
            .encode(AuthenticateData(token: token.token))
      // 5
      }).flatMapThrowing { response in
        // 6
        guard response.status == .ok else {
          if response.status == .unauthorized {
            throw Abort(.unauthorized)
          } else {
            throw Abort(.internalServerError)
          }
        }
        // 7
        let user = try response.content.decode(User.self)
        // 8
        request.auth.login(user)
      // 9
      }.flatMap {
        // 10
        return next.respond(to: request)
      }
    }
}

struct AuthenticateData: Content {
  let token: String
}
