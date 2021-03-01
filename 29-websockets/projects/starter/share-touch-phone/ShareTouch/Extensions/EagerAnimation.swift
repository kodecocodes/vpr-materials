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

/// a little eager to be pressed animation sequence 
struct Eager: ViewModifier {
    private let outmax = CGFloat(1.04)
    private let innmin = CGFloat(1)
    @State private var duration = TimeInterval(0.08)
    @State private var value = CGFloat(1.0)

    private enum Direction: Equatable {
        case outgoing, incoming
    }
    @State private var direction = Direction.outgoing

    func body(content: Content) -> some View {
            content
                .scaleEffect(y: value, anchor: .bottom)
                .animation(
                    Animation.spring(response: duration,
                                     dampingFraction: 0.25,
                                     blendDuration: duration),
                    value: value
                )
                .onAppear {
                    sequence(delay: { TimeInterval.random(in: (0.4...2.5)) })
                }
    }

    func sequence(delay: @escaping () -> TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay()) {
            duration = Int.random(in: 0...5) < 3 ? 0.35 : 0.24
            value = outmax
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                duration = Int.random(in: 0...5) < 3 ? 0.12 : 0.16
                value = innmin
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    sequence(delay: delay)
                }
            }
        }
    }
}
