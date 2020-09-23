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

/// Rejects requests that do not contain correct secret.
final class SecretMiddleware: Middleware {
  /// The secret expected in the `"X-Secret"` header.
  let secret: String

  /// Creates a new `SecretMiddleware`.
  ///
  /// - parameters:
  ///     - secret: The secret expected in the `"X-Secret"` header.
  init(secret: String) {
    self.secret = secret
  }

  /// See `Middleware`.
  func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
    guard request.http.headers.firstValue(name: .xSecret) == secret else {
      throw Abort(.unauthorized, reason: "Incorrect X-Secret header.")
    }

    return try next.respond(to: request)
  }
}

extension HTTPHeaderName {
  /// Contains a secret key.
  ///
  /// `HTTPHeaderName` wrapper for "X-Secret".
  static var xSecret: HTTPHeaderName {
    return .init("X-Secret")
  }
}

extension SecretMiddleware: ServiceType {
  /// See `ServiceType`.
  static func makeService(for worker: Container) throws -> SecretMiddleware {
    let secret: String
    switch worker.environment {
    case .development: secret = "foo"
    default:
      guard let envSecret = Environment.get("SECRET") else {
        throw Abort(.internalServerError, reason: "No $SECRET set on environment. Use `export SECRET=<secret>`")
      }
      secret = envSecret
    }
    return SecretMiddleware(secret: secret)
  }
}
