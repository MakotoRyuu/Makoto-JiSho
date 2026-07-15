import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("activeWordBookID") private var activeBookID: String = ""
    @Query(sort: \WordBook.createdAt) private var books: [WordBook]
    @Query private var allWords: [Word]
    @Query private var allProgressStates: [ProgressState]

    @State private var showFileImporter = false
    @State private var parsedWords: [ParsedWord] = []
    @State private var showImportPreview = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var bookToDelete: WordBook?

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Word Books
                Section {
                    ForEach(books) { book in
                        Button {
                            activeBookID = book.id
                        } label: {
                            HStack {
                                Label(book.name, systemImage: "book.closed")
                                    .foregroundStyle(.primary)
                                Spacer()
                                if book.id == activeBookID {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(DesignTokens.accent)
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        if let index = offsets.first {
                            bookToDelete = books[index]
                        }
                    }
                } header: {
                    Text("Word Books")
                }

                // MARK: - Import
                Section {
                    Button {
                        showFileImporter = true
                    } label: {
                        Label("Import words from txt file", systemImage: "doc.badge.plus")
                    }
                } header: {
                    Text("Import")
                } footer: {
                    Text("Each import creates a new word book.\nFormat: one word per line, english and chinese separated by a space.")
                }

                // MARK: - About
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showImportPreview) {
                ImportPreviewView(parsedWords: parsedWords)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.plainText]
            ) { result in
                handleFileImport(result)
            }
        }
        .alert("Delete Book?", isPresented: Binding(
            get: { bookToDelete != nil },
            set: { if !$0 { bookToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { bookToDelete = nil }
            Button("Delete", role: .destructive) {
                if let book = bookToDelete {
                    deleteBook(book)
                    bookToDelete = nil
                }
            }
        } message: {
            if let book = bookToDelete {
                Text("Delete \"\(book.name)\" and all its words? This cannot be undone.")
            }
        }
        .alert("Import Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }

    // MARK: - Book Management
    private func deleteBook(_ book: WordBook) {
        let bookID = book.id
        for word in allWords where word.wordBookID == bookID {
            modelContext.delete(word)
        }
        for progress in allProgressStates where (progress.bookID ?? "") == bookID {
            modelContext.delete(progress)
        }
        if book.id == activeBookID {
            let remaining = books.filter { $0.id != book.id }
            activeBookID = remaining.first?.id ?? ""
        }
        modelContext.delete(book)
        try? modelContext.save()
    }

    // MARK: - Import
    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = "Cannot read file"
                showError = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                parsedWords = try WordImporter.parse(url: url)
                print("[SettingsView] Parsed \(parsedWords.count) words")
                if parsedWords.isEmpty {
                    errorMessage = "No valid word format found in file"
                    showError = true
                } else {
                    showImportPreview = true
                }
            } catch {
                print("[SettingsView] Parse error: \(error)")
                errorMessage = error.localizedDescription
                showError = true
            }

        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }

}

#Preview {
    SettingsView()
        .modelContainer(for: [Word.self, ProgressState.self, WordBook.self])
}
