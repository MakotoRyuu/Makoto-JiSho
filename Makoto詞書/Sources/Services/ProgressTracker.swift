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

    /// Mark a word as reviewed in the current round.
    static func markReviewed(context: ModelContext, english: String, bookID: String?) {
        let bid = bookID ?? ""
        let wordPredicate = #Predicate<Word> { $0.english == english && $0.wordBookID == bid }
        let wordDescriptor = FetchDescriptor<Word>(predicate: wordPredicate)
        if let word = try? context.fetch(wordDescriptor).first {
            word.lastSeenAt = Date()
        }

        let progress = ensureExists(context: context, bookID: bookID)
        if !progress.reviewedEnglishWords.contains(english) {
            progress.reviewedEnglishWords.append(english)
        }

        checkRoundCompletion(context: context, progress: progress, bookID: bookID)
    }

    /// Check and handle round completion.
    static func checkRoundCompletion(context: ModelContext, progress: ProgressState, bookID: String?) {
        let totalCount = wordCount(context: context, bookID: bookID)
        guard totalCount > 0 else { return }

        if progress.reviewedEnglishWords.count >= totalCount {
            progress.completedRounds += 1
            progress.reviewedEnglishWords.removeAll()
        }
    }

    /// Save the current scroll position for resume.
    static func updateCurrentIndex(context: ModelContext, index: Int, bookID: String?) {
        let progress = ensureExists(context: context, bookID: bookID)
        progress.currentIndex = index
    }

    /// Reset progress for a given book.
    static func reset(context: ModelContext, bookID: String?) {
        let bid = bookID ?? ""
        let predicate = #Predicate<ProgressState> { $0.bookID == bid }
        var descriptor = FetchDescriptor<ProgressState>(predicate: predicate)
        descriptor.fetchLimit = 1
        if let progress = try? context.fetch(descriptor).first {
            progress.currentIndex = 0
            progress.completedRounds = 0
            progress.reviewedEnglishWords.removeAll()
            try? context.save()
        }
    }

    /// Count words for a given book using a predicate (not fetch-all).
    static func wordCount(context: ModelContext, bookID: String?) -> Int {
        let bid = bookID ?? ""
        let descriptor = FetchDescriptor<Word>(predicate: #Predicate<Word> { $0.wordBookID == bid })
        return (try? context.fetchCount(descriptor)) ?? 0
    }
}
