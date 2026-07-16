import SwiftData
import Foundation

@Model
final class Word {
    #Index<Word>([\.wordBookID], [\.wordBookID, \.createdAt], [\.wordBookID, \.english])

    var english: String
    var chinese: String
    var lastSeenAt: Date?
    var createdAt: Date
    var wordBookID: String?

    init(english: String, chinese: String, lastSeenAt: Date? = nil, createdAt: Date = .now, wordBookID: String? = nil) {
        self.english = english
        self.chinese = chinese
        self.lastSeenAt = lastSeenAt
        self.createdAt = createdAt
        self.wordBookID = wordBookID
    }
}
