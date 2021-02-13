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

extension Request {
  public var pokeAPI: PokeAPI {
    .init(client: self.client, cache: self.cache)
  }
}

/// A simple wrapper around the "pokeapi.co" API.
public final class PokeAPI {
  /// The HTTP client powering this API.
  let client: Client
  
  /// Cache to check before calling API.
  let cache: Cache
  
  /// Creates a new `PokeAPI` wrapper from the supplied client and cache.
  init(client: Client, cache: Cache) {
    self.client = client
    self.cache = cache
  }
  
  /// Returns `true` if the supplied Pokemon name is real.
  ///
  /// - parameter name: The name to verify.
  public func verify(name: String) -> EventLoopFuture<Bool> {
    /// Canonicalize input name.
    let name = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    
    /// Check cache first.
    return self.cache.get(name, as: Bool.self).flatMap { verified in
      if let verified = verified {
        return self.client.eventLoop.makeSucceededFuture(verified)
      } else {
        return self.uncachedVerify(name: name).flatMap { verified in
          /// Cache result for next time.
          return self.cache.set(name, to: verified)
            .transform(to: verified)
        }
      }
    }
  }

  private func uncachedVerify(name: String) -> EventLoopFuture<Bool> {
    /// Query the PokeAPI.
    return self.fetchPokemon(named: name).flatMapThrowing { res -> Bool in
      switch res.status.code {
      case 200..<300:
        /// The API returned 2xx which means this is a real Pokemon name
        return true
      case 404:
        /// The API returned a 404 meaning this Pokemon name was not found.
        return false
      default:
        /// The API returned a 500. Only thing we can do is forward the error.
        throw Abort(.internalServerError, reason: "Unexpected PokeAPI response: \(res.status)")
      }
    }
  }
  
  /// Fetches a pokemen with the supplied name from the PokeAPI.
  private func fetchPokemon(named name: String) -> EventLoopFuture<ClientResponse> {
    return self.client.get("https://pokeapi.co/api/v2/pokemon/\(name)")
  }
}
