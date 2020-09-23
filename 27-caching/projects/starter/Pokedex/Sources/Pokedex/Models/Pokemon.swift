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

import FluentSQLite
import Vapor

/// Represents a Pokemon we have captured and logged in our Pokedex.
final class Pokemon: SQLiteModel {
  /// See `Model.id`
  var id: Int?
  
  /// The Pokemon's name.
  var name: String
  
  /// See `Timestampable.createdAt`
  var createdAt: Date?
  
  /// See `Timestampable.updatedAt`
  var updatedAt: Date?
  
  /// Creates a new `Pokemon`.
  init(id: Int? = nil, name: String) {
    self.id = id
    self.name = name
  }
}

/// Allows this model to be parsed/serialized to HTTP messages
/// as JSON or any other supported format.
extension Pokemon: Content { }

/// Allows this Model to be used as its own database migration.
/// The database schema will be inferred from the Model's properties.
extension Pokemon: Migration { }

/// Allows this Model to be parameterized in Router paths.
extension Pokemon: Parameter { }

/// Allows Fluent to automatically update this Model's `createdAt`
/// and `updatedAt` properties as necessary.
extension Pokemon {
  static var createdAtKey: WritableKeyPath<Pokemon, Date?> {
    return \.createdAt
  }
  
  static var updatedAtKey: WritableKeyPath<Pokemon, Date?> {
    return \.updatedAt
  }
}
