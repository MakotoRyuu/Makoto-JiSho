import SwiftUI
import SwiftData

struct SwipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("activeWordBookID") private var activeBookID: String = ""

    // Display-only plain structs — zero SwiftData overhead during swiping
    @State private var entries: [(english: String, chinese: String)] = []
    @State private var currentIndex = 0
    @State private var reviewedIndices: Set<Int> = []
    @State private var completedRounds = 0
    @State private var roundJustCompleted = false

    // Background writer — all persistence happens off the main thread.
    @State private var persistence: PersistenceActor?

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
        .onChange(of: scenePhase) { _, phase in
            // Persist if the app is backgrounded mid-session, so progress
            // survives even if the app is killed without a manual close.
            if phase != .active {
                persistSnapshot(roundReset: false)
            }
        }
    }

    // MARK: - Data Loading (once on appear)

    private func loadData() {
        let bid = activeBookID.isEmpty ? nil : activeBookID

        // Load only the active book's words, sorted, in one indexed query.
        // Read the display fields up front, then drop all SwiftData references
        // so swiping is pure in-memory work.
        let descriptor = FetchDescriptor<Word>(
            predicate: #Predicate<Word> { $0.wordBookID == bid },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        let filtered = (try? modelContext.fetch(descriptor)) ?? []
        entries = filtered.map { (english: $0.english, chinese: $0.chinese) }

        // Background writer bound to the same store.
        persistence = PersistenceActor(modelContainer: modelContext.container)

        // Restore progress. Map saved english words → indices via a lookup
        // table (O(n)) instead of a per-word linear scan (O(n²)).
        let progress = ProgressTracker.ensureExists(context: modelContext, bookID: bid)
        var indexByEnglish = [String: Int](minimumCapacity: entries.count)
        for (i, entry) in entries.enumerated() where indexByEnglish[entry.english] == nil {
            indexByEnglish[entry.english] = i
        }
        reviewedIndices = Set(progress.reviewedEnglishWords.compactMap { indexByEnglish[$0] })
        completedRounds = progress.completedRounds
        currentIndex = min(progress.currentIndex, max(entries.count - 1, 0))
    }

    // MARK: - Swipe Actions (pure in-memory, zero SwiftData)

    private func swipeForward() {
        guard currentIndex < entries.count else { return }
        reviewedIndices.insert(currentIndex)

        if currentIndex < entries.count - 1 {
            // Pure in-memory advance — no persistence on the hot path.
            currentIndex += 1
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

    /// Snapshot the in-memory state and hand it to the background actor.
    /// Never touches the main-thread model context, so it never blocks the UI.
    private func persistSnapshot(roundReset: Bool) {
        guard let persistence else { return }
        let bid = activeBookID.isEmpty ? "" : activeBookID
        let reviewed = roundReset ? [] : reviewedIndices.map { entries[$0].english }
        let index = roundReset ? 0 : currentIndex
        let rounds = completedRounds
        Task.detached {
            await persistence.persist(
                bookID: bid,
                reviewedEnglishWords: reviewed,
                currentIndex: index,
                completedRounds: rounds
            )
        }
    }

    private func saveAndDismiss() {
        // Dismiss immediately — the write runs on a background actor, so the
        // close button responds instantly with no stutter.
        persistSnapshot(roundReset: roundJustCompleted)
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
