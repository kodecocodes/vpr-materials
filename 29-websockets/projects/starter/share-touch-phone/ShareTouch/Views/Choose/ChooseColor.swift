import SwiftUI

struct ChooseColorView: View {
    @State private var chosenColor = Color.yellow
    @State private var presentSharePad = false

    var body: some View {
        ZStack {
            VStack {
                Color.background
                chosenColor
            }
            .edgesIgnoringSafeArea([.top, .bottom])

            VStack(spacing: 0) {
                VStack {
                    Text("CHOOSE")
                        .style(fontSize: 24, .semibold)
                        .opacity(0.6)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    Text("YOUR")
                        .style(fontSize: 48, .semibold)
                        .opacity(0.78)
                        .padding(.bottom, 12)
                    Text("COLOR")
                        .style(fontSize: 80, .bold)
                }

                VStack {
                    Spacer()
                    ColorPicker("", selection: $chosenColor)
                        .labelsHidden()
                        .scaleEffect(4)
                    Spacer()
                }


                Spacer()

                HStack {
                    Spacer()
                    Text("BEGIN")
                        .foregroundColor(Color.black)
                        .style(fontSize: 60, .thin)
                    Spacer()
                }
                .padding([.leading, .trailing], 12)
                .background(chosenColor)
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .modifier(Eager())
                .onTapGesture {
                    presentSharePad = true
                }
            }
            .background(Color.background)
            .frame(alignment: .top)
            .sheet(
                isPresented: $presentSharePad,
                content: {
                    ShareColorPad(color: $chosenColor)
                }
            )
        }
    }
}

extension Text {
    fileprivate func style(fontSize: CGFloat, _ weight: Font.Weight) -> some View {
        self.font(.monospaced(size: fontSize))
            .fontWeight(.semibold)
            .minimumScaleFactor(0.5)
            .multilineTextAlignment(.center)
            .lineLimit(1)
    }
}

extension Font {
    static func monospaced(size: CGFloat) -> Font {
        Font.system(size: size, weight: .bold, design: .monospaced)
    }
}


struct Root_Previews: PreviewProvider {
    static var previews: some View {
        Root()
    }
}
