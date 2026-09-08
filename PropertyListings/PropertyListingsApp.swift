import SwiftUI

@main
struct PropertyListingsApp: App {
    @State private var composition = AppComposition()

    var body: some Scene {
        WindowGroup {
            RootView(composition: composition)
        }
    }
}
