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
        UnitPoint(x: x.clamped(low: area.minX, high: area.maxX),
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
