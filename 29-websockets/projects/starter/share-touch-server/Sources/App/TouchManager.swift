import Vapor

struct ActiveSession {
    var touch: SharedTouch
    let ws: WebSocket
}

/// for now, all touches come through one server
final class TouchManager {
    static let `default` = TouchManager()
    private init() {}

    @ThreadSafe
    private var participants: [String: ActiveSession] = [:]
    private func flush() {
        participants
            .filter { _, v in v.ws.isClosed }
            .map(\.key).forEach(self.remove)
    }

    func send(_ msg: Message) {
        flush()
        participants.values.forEach { p in
            guard p.touch.participant != msg.participant else { return }
            p.ws.send(msg)
        }
    }

    func insert(id: String, color: ColorComponents, at pt: RelativePoint, on ws: WebSocket) {
        print("new user joined")
    }

    func update(id: String, to pt: RelativePoint) {
        print("user moved to: \(pt)")
    }

    func remove(id: String) {
        participants[id] = nil
        print("remove user: \(id)")
    }
}
