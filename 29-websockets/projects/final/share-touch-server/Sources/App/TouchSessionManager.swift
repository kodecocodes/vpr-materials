import Vapor

struct ActiveSession {
    var touch: SharedTouch
    let ws: WebSocket
}

/// for now, all touches come through one server
final class TouchSessionManager {
    static let `default` = TouchSessionManager()
    private init() {

    }

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
        /// notify existing users of new user
        let start = SharedTouch(id: id,
                                color: color,
                                position: pt)
        let msg = Message(participant: id,
                          update: .joined(start))
        send(msg)

        /// notify new user of existing
        participants.values.map {
            Message(participant: $0.touch.participant,
                    update: .joined($0.touch))
        } .forEach { ws.send($0) }

        /// store new session
        let session = ActiveSession(touch: start, ws: ws)
        participants[id] = session
    }

    func update(id: String, to pt: RelativePoint) {
        participants[id]?.touch.position = pt
        let msg = Message(participant: id, update: .moved(pt))
        send(msg)
    }

    func remove(id: String) {
        participants[id] = nil
        let msg = Message(participant: id, update: .left)
        send(msg)
    }
}
