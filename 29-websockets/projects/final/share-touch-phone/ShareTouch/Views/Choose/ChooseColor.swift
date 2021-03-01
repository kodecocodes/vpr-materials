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

      // swiftlint:disable:next trailing_closure
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
  func style(fontSize: CGFloat, _ weight: Font.Weight) -> some View {
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
