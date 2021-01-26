import SwiftUI

extension ColorComponents {
    var color: Color {
        Color(cgColor)
    }

    var cgColor: CGColor {
        CGColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension Color {
    var components: ColorComponents {
        let comps = UIColor(self).cgColor.components ?? [1, 0.8, 0, 1]
        return ColorComponents(r: comps[0],
                               g: comps[1],
                               b: comps[2],
                               a: comps[3])
    }
}

