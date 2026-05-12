import SwiftUI

struct CoopOnHill: View {
    var size: CGFloat = 200

    var body: some View {
        Image("coop_house")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .allowsHitTesting(false)
    }
}
