import SwiftUI

extension String: Error {}

let shareSessionURL = "ws://localhost:8080/session"

struct Root: View {
    var body: some View {
        VStack {
            ChooseColorView().frame(alignment: .top)
        }
    }
}

@main
struct ShareTouchApp: App {
    var body: some Scene {
        WindowGroup {
            Root()
        }
    }
}

extension Color {
    static let background: Color = Color(red: 1, green: 0.988, blue: 0.966)
}
