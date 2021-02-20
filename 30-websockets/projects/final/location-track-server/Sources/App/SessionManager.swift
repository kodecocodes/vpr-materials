/// Copyright (c) 2019 Razeware LLC
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
import WebSocket

// MARK: For the purposes of this example, we're using a simple global collection.
// in production scenarios, this will not be scalable beyond a single server
// make sure to configure appropriately with a database like Redis to properly
// scale
final class TrackingSessionManager {
  // MARK: Member Variables
  
  private(set) var sessions: LockedDictionary<TrackingSession, [WebSocket]> = [:]
  
  // MARK: Observer Interactions
  
  func add(listener: WebSocket, to session: TrackingSession) {
    guard var listeners = sessions[session] else { return }
    listeners.append(listener)
    sessions[session] = listeners
    
    listener.onClose.always { [weak self, weak listener] in
      guard let listener = listener else { return }
      self?.remove(listener: listener, from: session)
    }
  }
  
  func remove(listener: WebSocket, from session: TrackingSession) {
    guard var listeners = sessions[session] else { return }
    listeners = listeners.filter { $0 !== listener }
    sessions[session] = listeners
  }
  
  // MARK: Poster Interactions
  
  func createTrackingSession(for request: Request) -> Future<TrackingSession> {
    return wordKey(with: request)
      .flatMap(to: TrackingSession.self) { [unowned self] key -> Future<TrackingSession> in
        let session = TrackingSession(id: key)
        guard self.sessions[session] == nil else {
          return self.createTrackingSession(for: request)
          
        }
        self.sessions[session] = []
        return Future.map(on: request) { session }
    }
  }
  
  func update(_ location: Location, for session: TrackingSession) {
    guard let listeners = sessions[session] else { return }
    listeners.forEach { ws in ws.send(location) }
  }
  
  func close(_ session: TrackingSession) {
    guard let listeners = sessions[session] else { return }
    listeners.forEach { ws in
      ws.close()
    }
    sessions[session] = nil
  }
}
