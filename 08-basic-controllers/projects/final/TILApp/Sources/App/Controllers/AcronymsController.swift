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
import Fluent

struct AcronymsController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let acronymsRoutes = routes.grouped("api", "acronyms")
    acronymsRoutes.get(use: getAllHandler)
    acronymsRoutes.post(use: createHandler)
    acronymsRoutes.get(":acronymID", use: getHandler)
    acronymsRoutes.put(":acronymID", use: updateHandler)
    acronymsRoutes.delete(":acronymID", use: deleteHandler)
    acronymsRoutes.get("search", use: searchHandler)
    acronymsRoutes.get("first", use: getFirstHandler)
    acronymsRoutes.get("sorted", use: sortedHandler)
  }
  
  func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
    Acronym.query(on: req.db).all()
  }
  
  func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
    let acronym = try req.content.decode(Acronym.self)
    return acronym.save(on: req.db).map { acronym }
  }

  func getHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
    Acronym.find(req.parameters.get("acronymID"), on: req.db)
    .unwrap(or: Abort(.notFound))
  }

  func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
    let updatedAcronym = try req.content.decode(Acronym.self)
    return Acronym.find(req.parameters.get("acronymID"), on: req.db)
      .unwrap(or: Abort(.notFound)).flatMap { acronym in
        acronym.short = updatedAcronym.short
        acronym.long = updatedAcronym.long
        return acronym.save(on: req.db).map {
          acronym
        }
    }
  }

  func deleteHandler(_ req: Request)
    throws -> EventLoopFuture<HTTPStatus> {
    Acronym.find(req.parameters.get("acronymID"), on: req.db)
      .unwrap(or: Abort(.notFound))
      .flatMap { acronym in
        acronym.delete(on: req.db)
          .transform(to: .noContent)
    }
  }

  func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
    guard let searchTerm = req
      .query[String.self, at: "term"] else {
      throw Abort(.badRequest)
    }
    return Acronym.query(on: req.db).group(.or) { or in
      or.filter(\.$short == searchTerm)
      or.filter(\.$long == searchTerm)
    }.all()
  }

  func getFirstHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
    return Acronym.query(on: req.db)
      .first()
      .unwrap(or: Abort(.notFound))
  }

  func sortedHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
    return Acronym.query(on: req.db).sort(\.$short, .ascending).all()
  }
}
