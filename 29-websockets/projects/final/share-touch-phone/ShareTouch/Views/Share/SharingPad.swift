import SwiftUI

struct ShareColorPad: View {
    @ObservedObject private var coords: ShareCoordinator

    init(color: Binding<Color>) {
        self.coords = .init(url: shareSessionURL, color: color)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ParticipantsPad(shared: $coords.ordered)

                ShareCircle(color: coords.color, highlight: true).position(
                    coords.position.absolutePoint(in: geo.size)
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            let end = drag.location.relativePoint(in: geo.size)
                            coords.position = end.clamped(in: .relativeVisible)
                        }
                )
                .background(Color.clear)
            }
        }
        .onAppear(perform: coords.connect)
        .onDisappear(perform: coords.disconnect)
    }
}
