import SwiftUI

struct AboutView: View {
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "character.book.closed.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(DesignTokens.accent)

                        Text("Makoto_JiSho")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)

                        Text("Version \(appVersion)")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
            }

            Section {
                LabeledContent("Developer", value: "Makoto Ryuu")
                LabeledContent("Platform", value: "iOS 18+")
            } header: {
                Text("Info")
            }

            Section {
                Text("Makoto_JiSho is a minimalist vocabulary app with a swipe-based interface inspired by short-form video apps. Simply swipe up and down to browse words — making learning lightweight and effortless.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            } header: {
                Text("About")
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
