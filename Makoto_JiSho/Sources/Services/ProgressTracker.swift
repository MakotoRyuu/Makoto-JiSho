import SwiftData
import Foundation

@MainActor
struct ProgressTracker {
    /// Fetch or create the ProgressState for a given book.
    static func ensureExists(context: ModelContext, bookID: String?) -> ProgressState {
        let bid = bookID ?? ""
        let predicate = #Predicate<ProgressState> { $0.bookID == bid }
        var descriptor = FetchDescriptor<ProgressState>(predicate: predicate)
        descriptor.fetchLimit = 1
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let state = ProgressState(bookID: bid)
        context.insert(state)
        try? context.save()
        return state
    }
}
