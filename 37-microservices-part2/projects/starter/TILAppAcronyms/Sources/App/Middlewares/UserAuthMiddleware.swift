import Vapor

struct UserAuthMiddleware: Middleware {
  func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
    guard let token = request.headers.bearerAuthorization else {
      return request.eventLoop.future(error: Abort(.unauthorized))
    }
    return request.client.post("http://localhost:8081/auth/authenticate", beforeSend: { authRequest in
      try authRequest.content.encode(AuthenticateData(token: token.token))
    }).flatMapThrowing { response in
      guard response.status == .ok else {
        if response.status == .unauthorized {
          throw Abort(.unauthorized)
        } else {
          throw Abort(.internalServerError)
        }
      }
      let user = try response.content.decode(User.self)
      request.auth.login(user)
    }.flatMap {
      return next.respond(to: request)
    }
  }
}

struct AuthenticateData: Content {
  let token: String
}
