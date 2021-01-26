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
