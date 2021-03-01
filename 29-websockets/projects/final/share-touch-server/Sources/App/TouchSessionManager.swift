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
