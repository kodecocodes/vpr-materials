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

#if os(iOS)

import SwiftUI

typealias FloatPreference = CGFloat
typealias RelativePoint = UnitPoint

extension UnitPoint: Codable {
  /// used just for mapping between the two
  private struct Mapping: Codable {
    let x: FloatPreference
    let y: FloatPreference
  }

  public init(from decoder: Decoder) throws {
    let map = try Mapping(from: decoder)
    self.init(x: map.x, y: map.y)
  }

  public func encode(to encoder: Encoder) throws {
    try Mapping(x: x, y: y).encode(to: encoder)
  }
}

#else

typealias FloatPreference = Double

/// a relative point
struct RelativePoint: Codable {
  let x: FloatPreference
  let y: FloatPreference
}

#endif

struct SharedTouch: Codable {
  let participant: String
  let colorComponents: ColorComponents
  var position: RelativePoint

  init(id: String, color: ColorComponents, position: RelativePoint) {
    self.participant = id
    self.colorComponents = color
    self.position = position
  }
}

struct ColorComponents: Codable {
  let red, green, blue, alpha: FloatPreference

  enum CodingKeys: String, CodingKey {
    case red = "r"
    case green = "g"
    case blue = "b"
    case alpha = "a"
  }
}

struct Message: Codable {
  let participant: String
  let update: Update

  enum Update: Codable {
    case joined(SharedTouch)
    case moved(RelativePoint)
    case left

    // swiftlint:disable:next nesting
    enum CodingKeys: String, CodingKey {
      case joined, moved, left
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      self = try Chain().do {
        let color = try container.decode(SharedTouch.self, forKey: .joined)
        return.joined(color)
      }
      .catch {
        let point = try container.decode(RelativePoint.self, forKey: .moved)
        return .moved(point)
      }
      .catch {
        _ = try container.decode(Bool.self, forKey: .left)
        return .left
      }
      .run()
    }

    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      switch self {
      case .joined(let color):
        try container.encode(color, forKey: .joined)
      case .moved(let point):
        try container.encode(point, forKey: .moved)
      case .left:
        try container.encode(true, forKey: .left)
      }
    }
  }
}

// MARK: 

extension Array: Error where Element: Error {}

class Chain<T> {
  var chain: [() throws -> T] = []

  func `do`(_ block: @escaping () throws -> T) -> Self {
    chain.append(block)
    return self
  }

  func `catch`(_ block: @escaping () throws -> T) -> Self {
    chain.append(block)
    return self
  }

  func run() throws -> T {
    return try consume([], chain)
  }

  private func consume(_ errors: [Error], _ chain: [() throws -> T]) throws -> T {
    var chain = chain
    guard !chain.isEmpty else { throw errors }
    let next = chain.removeFirst()
    do {
      return try next()
    } catch {
      return try consume(errors + [error], chain)
    }
  }
}

/**
```
enterRoom
(Color, Pt)  -------->
<-------- (Active Shared Touches)


onMove
(Pt)  -------->  server.broadcasts )))


joined
<-------- (NewId, Color, Pt)
moved
<-------- (Id, Pt)
```
*/
