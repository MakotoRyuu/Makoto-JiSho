import SwiftData
import Foundation

@Model
final class WordBook {
    @Attribute(.unique) var id: String
    var name: String
    var createdAt: Date

    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
        self.createdAt = .now
    }
}
