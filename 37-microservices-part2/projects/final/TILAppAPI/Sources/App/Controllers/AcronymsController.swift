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

struct AcronymsController: RouteCollection {
  let acronymsServiceURL: String
  let userServiceURL: String

  init(acronymsServiceHostname: String, userServiceHostname: String) {
    acronymsServiceURL = "http://\(acronymsServiceHostname):8082"
    userServiceURL = "http://\(userServiceHostname):8081"
  }

  func boot(routes: RoutesBuilder) throws {
    let acronymsGroup = routes.grouped("api", "acronyms")
    acronymsGroup.get(use: getAllHandler)
    acronymsGroup.get(":acronymID", use: getHandler)
    acronymsGroup.post(use: createHandler)
    acronymsGroup.put(":acronymID", use: updateHandler)
    acronymsGroup.delete(":acronymID", use: deleteHandler)
    acronymsGroup.get(":acronymID", "user", use: getUserHandler)
  }

  func getAllHandler(_ req: Request) -> EventLoopFuture<ClientResponse> {
    return req.client.get("\(acronymsServiceURL)/")
  }

  func getHandler(_ req: Request) throws -> EventLoopFuture<ClientResponse> {
    let id = try req.parameters.require("acronymID", as: UUID.self)
    return req.client.get("\(acronymsServiceURL)/\(id)")
  }

  func createHandler(_ req: Request) -> EventLoopFuture<ClientResponse> {
    return req.client.post("\(acronymsServiceURL)/") { createRequest in
      guard let authHeader = req.headers[.authorization].first else {
        throw Abort(.unauthorized)
      }
      createRequest.headers.add(name: .authorization, value: authHeader)
      try createRequest.content.encode(req.content.decode(CreateAcronymData.self))
    }
  }

  func updateHandler(_ req: Request) throws -> EventLoopFuture<ClientResponse> {
    let acronymID = try req.parameters.require("acronymID", as: UUID.self)
    return req.client.put("\(acronymsServiceURL)/\(acronymID)") { updateRequest in
      guard let authHeader = req.headers[.authorization].first else {
        throw Abort(.unauthorized)
      }
      updateRequest.headers.add(name: .authorization, value: authHeader)
      try updateRequest.content.encode(req.content.decode(CreateAcronymData.self))
    }
  }

  func deleteHandler(_ req: Request) throws -> EventLoopFuture<ClientResponse> {
    let acronymID = try req.parameters.require("acronymID", as: UUID.self)
    return req.client.delete("\(acronymsServiceURL)/\(acronymID)") { deleteRequest in
      guard let authHeader = req.headers[.authorization].first else {
        throw Abort(.unauthorized)
      }
      deleteRequest.headers.add(name: .authorization, value: authHeader)
    }
  }

  func getUserHandler(_ req: Request) throws -> EventLoopFuture<ClientResponse> {
    let acronymID = try req.parameters.require("acronymID", as: UUID.self)
    return req.client.get("\(acronymsServiceURL)/\(acronymID)").flatMapThrowing { response in
      return try response.content.decode(Acronym.self)
    }.flatMap { acronym in
      return req.client.get("\(userServiceURL)/users/\(acronym.userID)")
    }
  }
}

struct CreateAcronymData: Content {
  let short: String
  let long: String
}
