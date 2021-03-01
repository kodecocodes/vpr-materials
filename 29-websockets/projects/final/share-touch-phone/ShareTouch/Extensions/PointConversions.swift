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

import SwiftUI
import Foundation

extension CGPoint {
  func relativePoint(in size: CGSize) -> UnitPoint {
    let relX = x / size.width
    let relY = y / size.height
    return .init(x: relX, y: relY)
  }
}

extension UnitPoint {
  func absolutePoint(in size: CGSize) -> CGPoint {
    .init(x: x * size.width, y: y * size.height)
  }
}

extension UnitPoint {
  func clamped(in area: CGRect) -> UnitPoint {
    UnitPoint(
      x: x.clamped(low: area.minX, high: area.maxX),
      y: y.clamped(low: area.minY, high: area.maxY))
  }
}

extension CGRect {
  static let relativeVisible = CGRect(x: 0, y: 0, width: 1, height: 1)
}

extension FloatingPoint {
  func clamped(low: Self, high: Self) -> Self {
    Swift.max(Swift.min(self, high), low)
  }
}

extension Data {
  var string: String? { String(data: self, encoding: .utf8) }
}
