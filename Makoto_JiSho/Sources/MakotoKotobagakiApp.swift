import SwiftUI
import SwiftData

@main
struct MakotoKotobagakiApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [Word.self, ProgressState.self, WordBook.self])
    }
}
