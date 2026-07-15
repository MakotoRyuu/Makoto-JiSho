import SwiftUI

enum DesignTokens {
    // MARK: - Colors
    static let background = Color(.systemBackground)
    static let cardBackground = Color(.secondarySystemBackground)
    static let accent = Color.accentColor
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)

    // MARK: - Typography
    static let wordFont = Font.system(size: 48, weight: .bold, design: .rounded)
    static let meaningFont = Font.system(size: 28, weight: .medium, design: .rounded)
    static let statValueFont = Font.system(size: 36, weight: .heavy, design: .rounded)
    static let statLabelFont = Font.system(size: 14, weight: .regular, design: .rounded)

    // MARK: - Spacing
    static let cardPadding: CGFloat = 32
    static let statSpacing: CGFloat = 36
}
