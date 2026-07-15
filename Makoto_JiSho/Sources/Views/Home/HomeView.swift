import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("activeWordBookID") private var activeBookID: String = ""
    @Query(sort: \Word.createdAt) private var allWords: [Word]
    @Query private var allProgressStates: [ProgressState]

    @State private var showSwipe = false
    @State private var showSettings = false

    private var words: [Word] {
        let bid = activeBookID.isEmpty ? nil : activeBookID
        return allWords.filter { $0.wordBookID == bid }
    }

    private var progress: ProgressState? {
        let bid = activeBookID.isEmpty ? "" : activeBookID
        return allProgressStates.first { ($0.bookID ?? "") == bid }
    }

    private var totalWordCount: Int { words.count }
    private var currentRoundSeen: Int {
        progress?.reviewedEnglishWords.count ?? 0
    }
    private var completedRounds: Int {
        progress?.completedRounds ?? 0
    }

    @Query(sort: \WordBook.createdAt) private var allBooks: [WordBook]
    private var activeBookName: String? {
        guard !activeBookID.isEmpty else { return nil }
        return allBooks.first { $0.id == activeBookID }?.name
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if totalWordCount > 0 {
                    statsView
                } else {
                    emptyView
                }
            }
            .frame(maxWidth: .infinity)
            .background(DesignTokens.background.ignoresSafeArea())
            .navigationTitle(activeBookName ?? "Makoto詞書")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(DesignTokens.textSecondary)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showSwipe) {
            SwipeView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            let bid = activeBookID.isEmpty ? nil : activeBookID
            _ = ProgressTracker.ensureExists(context: modelContext, bookID: bid)
        }
        .onChange(of: activeBookID) { _, newBookID in
            let bid = newBookID.isEmpty ? nil : newBookID
            _ = ProgressTracker.ensureExists(context: modelContext, bookID: bid)
        }
    }

    // MARK: - Stats View
    private var statsView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                statRow(icon: "book.pages.fill", value: "\(totalWordCount)", label: "Total Words")
                statRow(icon: "checkmark.circle.fill", value: "\(currentRoundSeen)", label: "Reviewed")
                statRow(icon: "arrow.triangle.capsulepath", value: "\(completedRounds)", label: "Rounds")
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)

            VStack(spacing: 12) {
                ProgressView(value: Double(currentRoundSeen), total: Double(totalWordCount))
                    .tint(DesignTokens.accent)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal, 40)
                Text("Current Round: \(currentRoundSeen) / \(totalWordCount)")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(DesignTokens.textSecondary)
            }
            .padding(.top, 40)

            Button {
                showSwipe = true
            } label: {
                Text("Start Reviewing")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.accentColor)
                    )
            }
            .padding(.horizontal, 32)
            .padding(.top, 48)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Stat Row
    private func statRow(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 0) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(DesignTokens.accent)
                .frame(width: 44)
            Spacer().frame(width: 16)
            Text(value)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(DesignTokens.textPrimary)
                .contentTransition(.numericText())
                .frame(minWidth: 64, alignment: .leading)
            Spacer().frame(width: 16)
            Text(label)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(DesignTokens.textSecondary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(DesignTokens.cardBackground)
        )
    }

    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 56))
                .foregroundStyle(DesignTokens.textSecondary.opacity(0.5))
            Text("No words imported")
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(DesignTokens.textPrimary)
            Text("Tap the gear icon\nto import a word list")
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(DesignTokens.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Word.self, ProgressState.self, WordBook.self])
}
