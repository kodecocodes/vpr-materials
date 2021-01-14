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

struct CreateUser: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(User.v20210113.schemaName)
      .id()
      .field(User.v20210113.name, .string, .required)
      .field(User.v20210113.username, .string, .required)
      .field(User.v20210113.password, .string, .required)
      .unique(on: User.v20210113.username)
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(User.v20210113.schemaName).delete()
  }
}

extension User {
  enum v20210113 {
    static let schemaName = "users"
    static let id = FieldKey(stringLiteral: "id")
    static let name = FieldKey(stringLiteral: "name")
    static let username = FieldKey(stringLiteral: "username")
    static let password = FieldKey(stringLiteral: "password")
  }
}

