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
    let r, g, b, a: FloatPreference
}

struct Message: Codable {
    let participant: String
    let update: Update

    enum Update: Codable {
        case joined(SharedTouch)
        case moved(RelativePoint)
        case left

        enum CodingKeys: String, CodingKey {
            case joined, moved, left
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self = try Chain().do {
                let color = try container.decode(SharedTouch.self, forKey: .joined)
                return.joined(color)
            } .catch {
                let point = try container.decode(RelativePoint.self, forKey: .moved)
                return .moved(point)
            } .catch {
                let _ = try container.decode(Bool.self, forKey: .left)
                return .left
            } .run()
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .joined(let color):
                try container.encode(color, forKey: .joined)
            case .moved(let pt):
                try container.encode(pt, forKey: .moved)
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
