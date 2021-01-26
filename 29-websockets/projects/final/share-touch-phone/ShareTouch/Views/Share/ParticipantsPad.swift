import SwiftUI

struct ParticipantsPad: View {
    @Binding var shared: [SharedTouch]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(shared, id: \.participant) { touch in
                    ShareCircle(color: touch.colorComponents.color, highlight: false).position(
                        touch.position.absolutePoint(in: geo.size)
                    )
                    .transition(.slide)
                    .animation(.linear)
                    .id(touch.participant)
                }
            }
        }
    }
}
