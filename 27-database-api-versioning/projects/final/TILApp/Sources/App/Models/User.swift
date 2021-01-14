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

final class User: Model, Content {
  static let schema = User.v20210113.schemaName
  
  @ID
  var id: UUID?
  
  @Field(key: User.v20210113.name)
  var name: String
  
  @Field(key: User.v20210113.username)
  var username: String

  @Field(key: User.v20210113.password)
  var password: String
  
  @Children(for: \.$user)
  var acronyms: [Acronym]

  @OptionalField(key: User.v20210114.twitterURL)
  var twitterURL: String?
  
  init() {}
  
  init(id: UUID? = nil, name: String, username: String, password: String, twitterURL: String? = nil) {
    self.name = name
    self.username = username
    self.password = password
    self.twitterURL = twitterURL
  }

  final class Public: Content {
    var id: UUID?
    var name: String
    var username: String

    init(id: UUID?, name: String, username: String) {
      self.id = id
      self.name = name
      self.username = username
    }
  }

  final class PublicV2: Content {
    var id: UUID?
    var name: String
    var username: String
    var twitterURL: String?

    init(id: UUID?,
         name: String,
         username: String,
         twitterURL: String? = nil) {
      self.id = id
      self.name = name
      self.username = username
      self.twitterURL = twitterURL
    }
  }
}

extension User {
  func convertToPublic() -> User.Public {
    return User.Public(id: id, name: name, username: username)
  }

  func convertToPublicV2() -> User.PublicV2 {
    return User.PublicV2(id: id, name: name, username: username, twitterURL: twitterURL)
  }
}

extension EventLoopFuture where Value: User {
  func convertToPublic() -> EventLoopFuture<User.Public> {
    return self.map { user in
      return user.convertToPublic()
    }
  }

  func convertToPublicV2() -> EventLoopFuture<User.PublicV2> {
    return self.map { user in
      return user.convertToPublicV2()
    }
  }
}

extension Collection where Element: User {
  func convertToPublic() -> [User.Public] {
    return self.map { $0.convertToPublic() }
  }

  func convertToPublicV2() -> [User.PublicV2] {
    return self.map { $0.convertToPublicV2() }
  }
}

extension EventLoopFuture where Value == Array<User> {
  func convertToPublic() -> EventLoopFuture<[User.Public]> {
    return self.map { $0.convertToPublic() }
  }

  func convertToPublicV2() -> EventLoopFuture<[User.PublicV2]> {
    return self.map { $0.convertToPublicV2() }
  }
}

extension User: ModelAuthenticatable {
  static let usernameKey = \User.$username
  static let passwordHashKey = \User.$password

  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.password)
  }
}

extension User: ModelSessionAuthenticatable {}
extension User: ModelCredentialsAuthenticatable {}
