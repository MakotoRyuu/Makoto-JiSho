import SwiftUI
import SwiftData

struct ImportPreviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("activeWordBookID") private var activeBookID: String = ""

    let parsedWords: [ParsedWord]

    @State private var bookName = ""
    @State private var showResult = false
    @State private var resultMessage = ""
    @State private var isImporting = false

    var body: some View {
        ZStack {
            List {
                Section {
                    TextField("Book Name", text: $bookName)
                        .font(.system(.body, design: .rounded))
                } header: {
                    Text("New Word Book")
                }

                Section {
                    ForEach(parsedWords.indices, id: \.self) { index in
                        let word = parsedWords[index]
                        HStack {
                            Text(word.english)
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                            Spacer()
                            Text(word.chinese)
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Preview: \(parsedWords.count) words")
                }
            }
            .disabled(isImporting)

            // Loading overlay
            if isImporting {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Importing...")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
            }
        }
        .navigationTitle("Import Words")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .disabled(isImporting)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Import") {
                    startImport()
                }
                .disabled(parsedWords.isEmpty || isImporting)
            }
        }
        .alert("Import Complete", isPresented: $showResult) {
            Button("OK") { dismiss() }
        } message: {
            Text(resultMessage)
        }
    }

    private func startImport() {
        isImporting = true
        let name = bookName.trimmingCharacters(in: .whitespaces)
        let finalName = name.isEmpty ? "Untitled" : name
        let parsed = parsedWords

        Task { @MainActor in
            // Brief yield to let the loading UI appear
            await Task.yield()

            // Create new book
            let book = WordBook(name: finalName)
            modelContext.insert(book)
            try? modelContext.save()

            // Import words into the new book
            let (inserted, updated) = WordImporter.save(
                context: modelContext,
                parsed: parsed,
                bookID: book.id
            )

            // Set as active
            activeBookID = book.id
            resultMessage = "Added \(inserted), updated \(updated) words"
            isImporting = false
            showResult = true
        }
    }
}

#Preview {
    NavigationStack {
        ImportPreviewView(parsedWords: [
            ParsedWord(english: "apple", chinese: "apple"),
            ParsedWord(english: "book", chinese: "book")
        ])
    }
    .modelContainer(for: [Word.self, ProgressState.self, WordBook.self])
}
