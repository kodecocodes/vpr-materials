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

struct UsersController: RouteCollection {
  let userServiceURL: String
  let acronymsServiceURL: String
  
  init(userServiceHostname: String, acronymsServiceHostname: String) {
    userServiceURL = "http://\(userServiceHostname):8081"
    acronymsServiceURL = "http://\(acronymsServiceHostname):8082"
  }
  
  func boot(routes: RoutesBuilder) throws {
    let routeGroup = routes.grouped("api", "users")
    routeGroup.get(use: getAllHandler)
    routeGroup.get(":userID", use: getHandler)
    routeGroup.post(use: createHandler)
    routeGroup.post("login", use: loginHandler)
    routeGroup.get(":userID", "acronyms", use: getAcronyms)
  }
  
  func getAllHandler(_ req: Request) -> EventLoopFuture<ClientResponse> {
    return req.client.get("\(userServiceURL)/users")
  }
  
  func getHandler(_ req: Request) throws -> EventLoopFuture<ClientResponse> {
    let id = try req.parameters.require("userID", as: UUID.self)
    return req.client.get("\(userServiceURL)/users/\(id)")
  }
  
  func createHandler(_ req: Request) -> EventLoopFuture<ClientResponse> {
    return req.client.post("\(userServiceURL)/users") {
      createRequest in
      try createRequest.content.encode(req.content.decode(CreateUserData.self))
    }
  }
  
  func loginHandler(_ req: Request) -> EventLoopFuture<ClientResponse> {
    return req.client.post("\(userServiceURL)/auth/login") { loginRequest in
      guard let authHeader = req.headers[.authorization].first else {
        throw Abort(.unauthorized)
      }
      loginRequest.headers.add(name: .authorization, value: authHeader)
    }
  }
  
  func getAcronyms(_ req: Request) throws -> EventLoopFuture<ClientResponse> {
    // 1
    let userID = try req.parameters.require("userID", as: UUID.self)
    // 2
    return req.client
      .get("\(acronymsServiceURL)/user/\(userID)")
  }
}

struct CreateUserData: Content {
  let name: String
  let username: String
  let password: String
}
