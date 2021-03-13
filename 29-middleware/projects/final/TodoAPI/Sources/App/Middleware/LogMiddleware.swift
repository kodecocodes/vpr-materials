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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Vapor

/// Logs all requests that pass through it.
final class LogMiddleware: Middleware {
  /// Creates a new `LogMiddleware`.
  init() { }

  /// See `Middleware`.
  func respond(to req: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
    let start = Date()
    return next.respond(to: req).map { res in
      self.log(res, start: start, for: req)
      return res
    }
  }

  /// Logs a `Response` passing through this middleware.
  ///
  /// - parameters:
  ///     - result: Response result, either an `Error` or the actual `Response`.
  ///     - start: Start time for this request, should be created before the application starts responding.
  ///     - req: The `Request` this response was created for.
  func log(_ res: Response, start: Date, for req: Request) {
    let reqInfo = "\(req.method.string) \(req.url.path)"
    let resInfo = "\(res.status.code) \(res.status.reasonPhrase)"
    let time = Date().timeIntervalSince(start).readableMilliseconds
    req.logger.info("\(reqInfo) -> \(resInfo) [\(time)]")
  }
}

extension TimeInterval {
  /// Converts the time internal to readable milliseconds format, i.e., "3.4ms"
  var readableMilliseconds: String {
    let string = (self * 1000).description
    // include one decimal point after the zero
    let endIndex = string.index(string.firstIndex(of: ".")!, offsetBy: 2)
    let trimmed = string[string.startIndex..<endIndex]
    return .init(trimmed) + "ms"
  }
}
