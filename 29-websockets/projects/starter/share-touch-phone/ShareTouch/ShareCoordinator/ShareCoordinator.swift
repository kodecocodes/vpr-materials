import SwiftUI
import Foundation
import Combine

class ShareCoordinator: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    @Published private(set) var participants: [String: SharedTouch] = [:] {
        didSet {
            ordered = participants.map(\.value).sorted { $0.participant < $1.participant }
        }
    }
    @Published var ordered: [SharedTouch] = []

    @Binding var color: Color
    @Published var position: UnitPoint = .center

    private var cancellables = [AnyCancellable]()
    let url: String

    init(url: String, color: Binding<Color>) {
        self.url = url
        self._color = color
        super.init()

        $position
            .sink(receiveCompletion: { _ in
                fatalError("this shouldn't happen?")
            }, receiveValue: { [weak self] update in
                self?.send(position: update)
            })
            .store(in: &cancellables)
    }

    private func send(position: RelativePoint) {
        guard let str = try? JSONEncoder().encode(position).string else {
            print("couldn't encode update: \(position)")
            return
        }

        self.ws?.send(.string(str)) { err in
            guard let err = err else { return }
            print("error: \(err)")
        }
    }

    private var ws: URLSessionWebSocketTask? = nil

    private func on(msg: Message) {
        DispatchQueue.main.async {
            switch msg.update {
            case .moved(let pt):
                self.participants[msg.participant]?.position = .init(x: pt.x, y: pt.y)
            case .joined(let shared):
                self.participants[msg.participant] = shared
            case .left:
                self.participants[msg.participant] = nil
            }
        }
    }

    private lazy var session: URLSession = URLSession(configuration: .default,
                                                      delegate: self,
                                                      delegateQueue: nil)

    func connect() {
        guard ws == nil else { fatalError() }
        let comps = color.components
        let query = "r=\(comps.r)&g=\(comps.g)&b=\(comps.b)&a=\(comps.a)&x=\(position.x)&y=\(position.y)"
        let url = URL(string: "\(self.url)?\(query)")!
        let ws = session.webSocketTask(with: url)
        self.ws = ws
        listen()

        ws.resume()
    }

    func disconnect() {
        ws?.cancel(with: .goingAway, reason: nil)
    }

    var keepListening = true

    func listen() {
        ws?.receive { [weak self] result in
            switch result {
            case .success(let raw):
                do {
                    let msg = try Message(raw)
                    self?.on(msg: msg)
                } catch {
                    print(error.localizedDescription)
                    print("msg: \(raw)")
                }
                if self?.keepListening == true {
                    self?.listen()
                }
            case .failure(let err):
                print("error: \(err)")
                self?.ws = nil
                self?.connect()
            }
        }
    }


    deinit {
        ws?.cancel()
    }

    func cancel() {
        ws?.cancel(with: .goingAway, reason: nil)
        ws = nil
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?) {
        listen()
        webSocketTask.resume()
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?) {
        print("didClose")
    }
}

extension Decodable {
    init(_ msg: URLSessionWebSocketTask.Message) throws {
        let js = JSONDecoder()
        let data: Data
        switch msg {
        case .data(let d):
            data = d
        case .string(let s):
            data = .init(s.utf8)
        @unknown default:
            throw "unknown"
        }
        self = try js.decode(Self.self, from: data)
    }
}
