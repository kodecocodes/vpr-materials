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
import Fluent

struct AcronymsController: RouteCollection {
  func boot(router: Router) throws {
    router.get(use: getAllHandler)
    router.get(Acronym.parameter, use: getHandler)
    router.get("user", UUID.parameter, use: getUsersAcronyms)
    
    let authGroup = router.grouped(UserAuthMiddleware())
    authGroup.post(use: createHandler)
    authGroup.delete(Acronym.parameter, use: deleteHandler)
    authGroup.put(Acronym.parameter, use: updateHandler)
  }
  
  func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
    return Acronym.query(on: req).all()
  }
  
  func getHandler(_ req: Request) throws -> Future<Acronym> {
    return try req.parameters.next(Acronym.self)
  }
  
  func createHandler(_ req: Request) throws -> Future<Acronym> {
    let data = try req.content.syncDecode(AcronymData.self)
    let user = try req.requireAuthenticated(User.self)
    let acronym = Acronym(short: data.short, long: data.long, userID: user.id)
    return acronym.save(on: req)
  }
  
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Acronym.self).delete(on: req).transform(to: .noContent)
  }
  
  func updateHandler(_ req: Request) throws -> Future<Acronym> {
    return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(AcronymData.self)) { acronym, updateData in
      acronym.short = updateData.short
      acronym.long = updateData.long
      let user = try req.requireAuthenticated(User.self)
      acronym.userID = user.id
      return acronym.save(on: req)
    }
  }
  
  func getUsersAcronyms(_ req: Request) throws -> Future<[Acronym]> {
    let userID = try req.parameters.next(UUID.self)
    return Acronym.query(on: req).filter(\.userID == userID).all()
  }
}

struct AcronymData: Content {
  let short: String
  let long: String
}
