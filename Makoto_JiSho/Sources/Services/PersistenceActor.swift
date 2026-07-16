import SwiftData
import Foundation

/// Runs all SwiftData writes for the swipe flow on a background context,
/// keeping the main thread free so swiping and dismissing never stutter.
@ModelActor
actor PersistenceActor {
    /// Persist a swipe-session snapshot: progress fields plus `lastSeenAt`
    /// on every reviewed word. Runs off the main thread.
    func persist(
        bookID: String,
        reviewedEnglishWords: [String],
        currentIndex: Int,
        completedRounds: Int
    ) {
        // Update progress state (create if missing — mirrors ensureExists).
        let progress = fetchOrCreateProgress(bookID: bookID)
        progress.currentIndex = currentIndex
        progress.reviewedEnglishWords = reviewedEnglishWords
        progress.completedRounds = completedRounds

        // Stamp lastSeenAt on the reviewed words, scoped to this book.
        if !reviewedEnglishWords.isEmpty {
            let reviewed = Set(reviewedEnglishWords)
            let descriptor = FetchDescriptor<Word>(
                predicate: #Predicate<Word> { $0.wordBookID == bookID }
            )
            if let words = try? modelContext.fetch(descriptor) {
                let now = Date()
                for word in words where reviewed.contains(word.english) {
                    word.lastSeenAt = now
                }
            }
        }

        try? modelContext.save()
    }

    private func fetchOrCreateProgress(bookID: String) -> ProgressState {
        var descriptor = FetchDescriptor<ProgressState>(
            predicate: #Predicate<ProgressState> { $0.bookID == bookID }
        )
        descriptor.fetchLimit = 1
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let state = ProgressState(bookID: bookID)
        modelContext.insert(state)
        return state
    }
}
