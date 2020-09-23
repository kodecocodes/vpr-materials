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

import Foundation

let host = "localhost:8080"

final class WebServices {
  static let baseURL = "http://\(host)/"
  
  static let createURL = URL(string: baseURL + "create/")!
  static let updateURL = URL(string: baseURL + "update/")!
  static let closeURL = URL(string: baseURL + "close/")!
  
  static func create(
    success: @escaping (TrackingSession) -> Void,
    failure: @escaping (Error) -> Void
    ) {
    var request = URLRequest(url: createURL)
    request.httpMethod = "POST"
    URLSession.shared.objectRequest(with: request, success: success, failure: failure)
  }
  
  static func update(
    _ location: Location,
    for session: TrackingSession,
    completion: @escaping (Bool) -> Void
    ) {
    let url = updateURL.appendingPathComponent(session.id)
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    do {
      try request.addJSONBody(location)
    } catch {
      completion(false)
      return
    }
    
    URLSession.shared.dataRequest(
      with: request,
      success: { _ in completion(true) },
      failure: { _ in completion(false) }
    )
  }
  
  static func close(
    _ session: TrackingSession,
    completion: @escaping (Bool) -> Void
    ) {
    let url = closeURL.appendingPathComponent(session.id)
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    URLSession.shared.dataRequest(
      with: request,
      success: { _ in completion(true) },
      failure: { _ in completion(false) }
    )
  }
}

extension URLRequest {
  mutating func addJSONBody<C: Codable>(_ object: C) throws {
    let encoder = JSONEncoder()
    httpBody = try encoder.encode(object)
    setValue("application/json", forHTTPHeaderField: "Content-Type")
  }
}
