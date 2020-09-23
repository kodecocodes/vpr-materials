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

struct UsersController: RouteCollection {
  let userServiceURL: String
  let acronymsServiceURL: String
  
  init(userServiceHostname: String, acronymsServiceHostname: String) {
    userServiceURL = "http://\(userServiceHostname):8081"
    acronymsServiceURL = "http://\(acronymsServiceHostname):8082"
  }

  func boot(router: Router) throws {
    let routeGroup = router.grouped("api", "users")
    routeGroup.get(use: getAllHandler)
    routeGroup.get(UUID.parameter, use: getHandler)
    routeGroup.post(use: createHandler)
    routeGroup.post("login", use: loginHandler)
    routeGroup.get(UUID.parameter, "acronyms", use: getAcronyms)
  }
  
  func getAllHandler(_ req: Request) throws -> Future<Response> {
    return try req.client().get("\(userServiceURL)/users")
  }
  
  func getHandler(_ req: Request) throws -> Future<Response> {
    let id = try req.parameters.next(UUID.self)
    return try req.client().get("\(userServiceURL)/users/\(id)")
  }
  
  func createHandler(_ req: Request) throws -> Future<Response> {
    return try req.client().post("\(userServiceURL)/users") { createRequest in
      try createRequest.content.encode(req.content.syncDecode(CreateUserData.self))
    }
  }
  
  func loginHandler(_ req: Request) throws -> Future<Response> {
    return try req.client().post("\(userServiceURL)/auth/login") { loginRequest in
      guard let authHeader = req.http.headers[.authorization].first else {
        throw Abort(.unauthorized)
      }
      loginRequest.http.headers.add(name: .authorization, value: authHeader)
    }
  }
  
  func getAcronyms(_ req: Request) throws -> Future<Response> {
    let userID = try req.parameters.next(UUID.self)
    return try req.client().get("\(acronymsServiceURL)/user/\(userID)")
  }
}

struct CreateUserData: Content {
  let name: String
  let username: String
  let password: String
}
