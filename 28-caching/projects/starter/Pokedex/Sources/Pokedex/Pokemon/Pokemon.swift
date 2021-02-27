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

import Fluent
import Vapor

/// Represents a Pokemon we have captured and logged in our Pokedex.
final class Pokemon: Model {
  static let schema = "pokemon"
  
  /// See `Model.id`
  @ID(key: .id)
  var id: UUID?
  
  /// The Pokemon's name.
  @Field(key: "name")
  var name: String
  
  /// See `Timestampable.createdAt`
  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?
  
  /// See `Timestampable.updatedAt`
  @Timestamp(key: "updated_at", on: .update)
  var updatedAt: Date?
  
  init() { }
  
  /// Creates a new `Pokemon`.
  init(id: UUID? = nil, name: String) {
    self.id = id
    self.name = name
  }
}

/// Allows this model to be parsed/serialized to HTTP messages
/// as JSON or any other supported format.
extension Pokemon: Content { }

/// Allows this Model to be used as its own database migration.
/// The database schema will be inferred from the Model's properties.
struct CreatePokemon: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema("pokemon")
      .id()
      .field("name", .string, .required)
      .field("created_at", .datetime)
      .field("updated_at", .datetime)
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema("pokemon").delete()
  }
}
