import SwiftUI

@main
struct PropertyListingsApp: App {
    @State private var composition = AppComposition.launch()

    var body: some Scene {
        WindowGroup {
            RootView(composition: composition)
        }
    }
}
