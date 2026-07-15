import SwiftData
import Foundation

struct ParsedWord {
    let english: String
    let chinese: String
}

struct WordImporter {
    /// Parse a .txt file into an array of ParsedWord.
    static func parse(url: URL) throws -> [ParsedWord] {
        let content = try String(contentsOf: url, encoding: .utf8)
        return content
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .compactMap { line in
                let parts = line.split(separator: " ", maxSplits: 1)
                guard parts.count == 2 else { return nil }
                return ParsedWord(
                    english: String(parts[0]),
                    chinese: String(parts[1])
                )
            }
    }

    /// Save parsed words into SwiftData. Checks for duplicates within the same book
    /// and handles duplicates within the import file itself.
    static func save(context: ModelContext, parsed: [ParsedWord], bookID: String?) -> (inserted: Int, updated: Int) {
        var inserted = 0
        var updated = 0
        let allWords = (try? context.fetch(FetchDescriptor<Word>())) ?? []
        var seenInBatch = Set<String>()

        for word in parsed {
            let english = word.english
            let chinese = word.chinese

            // Skip duplicates within the same import file
            if seenInBatch.contains(english) {
                updated += 1
                continue
            }
            seenInBatch.insert(english)

            // Check for existing word in the same book
            if let existing = allWords.first(where: { $0.english == english && $0.wordBookID == bookID }) {
                existing.chinese = chinese
                updated += 1
            } else {
                context.insert(Word(english: english, chinese: chinese, wordBookID: bookID))
                inserted += 1
            }
        }

        try? context.save()
        return (inserted, updated)
    }
}
