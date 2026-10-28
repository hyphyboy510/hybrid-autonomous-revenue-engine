import SwiftUI

@main
struct HybridRevenueEngineApp: App {
    @StateObject private var store = RevenueStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
