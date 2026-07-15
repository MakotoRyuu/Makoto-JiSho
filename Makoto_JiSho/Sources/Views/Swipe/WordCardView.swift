import SwiftUI

struct WordCardView: View {
    let english: String
    let chinese: String

    var body: some View {
        ZStack {
            DesignTokens.cardBackground

            VStack(spacing: 24) {
                Text(english)
                    .font(DesignTokens.wordFont)
                    .foregroundStyle(DesignTokens.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.cardPadding)

                Text(chinese)
                    .font(DesignTokens.meaningFont)
                    .foregroundStyle(DesignTokens.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.cardPadding)
            }
        }
        .ignoresSafeArea()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(english), \(chinese)")
    }
}

#Preview {
    WordCardView(english: "serendipity", chinese: "意外發現的美好")
}
