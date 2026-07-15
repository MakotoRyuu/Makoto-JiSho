import SwiftUI
import SwiftData

struct SwipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("activeWordBookID") private var activeBookID: String = ""

    // Display-only plain structs — zero SwiftData overhead during swiping
    @State private var entries: [(english: String, chinese: String)] = []
    @State private var currentIndex = 0
    @State private var reviewedIndices: Set<Int> = []
    @State private var completedRounds = 0
    @State private var roundJustCompleted = false

    // Persistence handles — loaded once, only touched on save
    @State private var wordObjects: [String: Word] = [:]  // english → Word
    @State private var progressState: ProgressState?
    @State private var hasUnsavedChanges = false
    @State private var saveTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            DesignTokens.background.ignoresSafeArea()

            if entries.isEmpty {
                emptyView
            } else if currentIndex < entries.count {
                let entry = entries[currentIndex]
                WordCardView(english: entry.english, chinese: entry.chinese)
                    .transition(.identity)
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { saveAndDismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 8)
                }
                Spacer()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    guard !entries.isEmpty else { return }
                    if value.translation.height < 0 {
                        swipeForward()
                    } else if value.translation.height > 0 {
                        swipeBackward()
                    }
                }
        )
        .alert("Round Completed! 🎉", isPresented: $roundJustCompleted) {
            Button("OK") { saveAndDismiss() }
        } message: {
            Text("You've reviewed all \(entries.count) words. Great job!")
        }
        .onAppear {
            loadData()
        }
    }

    // MARK: - Data Loading (once on appear)

    private func loadData() {
        let bid = activeBookID.isEmpty ? nil : activeBookID

        // Load SwiftData objects into a dictionary for later batch-update
        let all = (try? modelContext.fetch(FetchDescriptor<Word>(sortBy: [SortDescriptor(\.createdAt)]))) ?? []
        let filtered = all.filter { $0.wordBookID == bid }
        wordObjects = Dictionary(uniqueKeysWithValues: filtered.compactMap { w in
            w.english.isEmpty ? nil : (w.english, w)
        })

        // Plain structs for display — no SwiftData references
        entries = filtered.map { (english: $0.english, chinese: $0.chinese) }

        // Load progress
        let progress = ProgressTracker.ensureExists(context: modelContext, bookID: bid)
        progressState = progress

        reviewedIndices = Set(progress.reviewedEnglishWords.compactMap { english in
            entries.firstIndex(where: { $0.english == english })
        })
        completedRounds = progress.completedRounds
        currentIndex = min(progress.currentIndex, max(entries.count - 1, 0))
    }

    // MARK: - Swipe Actions (pure in-memory, zero SwiftData)

    private func swipeForward() {
        guard currentIndex < entries.count else { return }
        reviewedIndices.insert(currentIndex)

        if currentIndex < entries.count - 1 {
            currentIndex += 1
            scheduleSave()
        } else {
            // Last word — check round completion
            if reviewedIndices.count >= entries.count && !entries.isEmpty {
                completedRounds += 1
                roundJustCompleted = true
            } else {
                saveAndDismiss()
            }
        }
    }

    private func swipeBackward() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }

    // MARK: - Save & Dismiss

    private func scheduleSave() {
        hasUnsavedChanges = true
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            flushSave()
        }
    }

    /// Batch-write all pending changes to SwiftData in one pass.
    private func flushSave() {
        guard hasUnsavedChanges else { return }
        hasUnsavedChanges = false

        // Batch-update lastSeenAt on Word objects
        let now = Date()
        for index in reviewedIndices {
            let english = entries[index].english
            wordObjects[english]?.lastSeenAt = now
        }

        // Update progress
        if let progress = progressState {
            progress.currentIndex = currentIndex
            progress.reviewedEnglishWords = reviewedIndices.map { entries[$0].english }
            progress.completedRounds = completedRounds
        }

        try? modelContext.save()
    }

    private func saveAndDismiss() {
        saveTask?.cancel()

        // Batch-update lastSeenAt
        let now = Date()
        for index in reviewedIndices {
            let english = entries[index].english
            wordObjects[english]?.lastSeenAt = now
        }

        // Update progress
        if let progress = progressState {
            progress.currentIndex = roundJustCompleted ? 0 : currentIndex
            progress.reviewedEnglishWords = roundJustCompleted ? [] : reviewedIndices.map { entries[$0].english }
            progress.completedRounds = completedRounds
        }

        try? modelContext.save()
        dismiss()
    }

    // MARK: - Empty State

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(DesignTokens.textSecondary.opacity(0.5))
            Text("No words")
                .font(.system(.title3, design: .rounded))
                .foregroundStyle(DesignTokens.textPrimary)
            Text("Import a word list first")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(DesignTokens.textSecondary)
        }
    }
}

#Preview {
    SwipeView()
        .modelContainer(for: [Word.self, ProgressState.self, WordBook.self])
}
