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

import FluentSQLite
import Vapor

/// Controllers querying and storing new Pokedex entries.
final class PokemonController {
  /// Lists all known pokemon in our pokedex.
  func index(_ req: Request) throws -> Future<[Pokemon]> {
    return Pokemon.query(on: req).all()
  }
  
  /// Stores a newly discovered pokemon in our pokedex.
  func create(_ req: Request, _ newPokemon: Pokemon) throws -> Future<Pokemon> {
    /// Check to see if the pokemon already exists
    return Pokemon.query(on: req).filter(\.name == newPokemon.name).count().flatMap { count -> Future<Bool> in
        /// Ensure number of Pokemon with the same name is zero
        guard count == 0 else {
          throw Abort(.badRequest, reason: "You already caught \(newPokemon.name).")
        }
          
        /// Check if the pokemon is real. This will throw an error aborting
        /// the request if the pokemon is not real.
        return try req.make(PokeAPI.self).verifyName(newPokemon.name, on: req)
      }.flatMap { nameVerified -> Future<Pokemon> in
        /// Ensure the name verification returned true, or throw an error
        guard nameVerified else {
          throw Abort(.badRequest, reason: "Invalid Pokemon \(newPokemon.name).")
        }
        
        /// Save the new Pokemon
        return newPokemon.save(on: req)
    }
  }
}
