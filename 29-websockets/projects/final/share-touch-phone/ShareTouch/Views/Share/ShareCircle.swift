import SwiftUI

struct ShareCircle: View {
    let color: Color
    let highlight: Bool

    var body: some View {
        ZStack {
            color.mask(Circle())

            if highlight {
                Color.green
                    .frame(width: 4, height: 4)
                    .position(x: 2, y: 2)
                    .cornerRadius(2)
            }
        }
        .frame(width: 36, height: 36)
    }
}

