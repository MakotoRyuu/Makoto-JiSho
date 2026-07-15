import SwiftData
import Foundation

@Model
final class ProgressState {
    var bookID: String?
    var currentIndex: Int = 0
    var completedRounds: Int = 0
    var reviewedEnglishWords: [String] = []

    init(bookID: String? = nil) {
        self.bookID = bookID
    }
}
