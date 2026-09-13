import DesignSystem
import SwiftUI

struct LaunchView: View {
    @State private var composition: AppComposition?

    var body: some View {
        ZStack {
            CurrentBrand.configuration.theme.colors.surface
                .ignoresSafeArea()
            
            if let composition {
                RootView(composition: composition)
            }
        }
        .task { composition = await AppComposition.launch() }
    }
}
