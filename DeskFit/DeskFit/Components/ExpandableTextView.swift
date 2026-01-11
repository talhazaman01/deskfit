import SwiftUI

/// A text view that truncates to a specified number of lines with a "More"/"Less" toggle
struct ExpandableTextView: View {
    let text: String
    let lineLimit: Int
    let font: Font
    let foregroundColor: Color
    let moreButtonColor: Color

    @State private var isExpanded = false
    @State private var isTruncated = false
    @State private var intrinsicHeight: CGFloat = 0
    @State private var truncatedHeight: CGFloat = 0

    init(
        text: String,
        lineLimit: Int,
        font: Font = Theme.Typography.body,
        foregroundColor: Color = .textSecondary,
        moreButtonColor: Color = .primary
    ) {
        self.text = text
        self.lineLimit = lineLimit
        self.font = font
        self.foregroundColor = foregroundColor
        self.moreButtonColor = moreButtonColor
    }

    var body: some View {
        VStack(alignment: .center, spacing: Theme.Spacing.xs) {
            Text(text)
                .font(font)
                .foregroundStyle(foregroundColor)
                .multilineTextAlignment(.center)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(
                    // Measure truncated height
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: TruncatedHeightPreferenceKey.self,
                            value: geometry.size.height
                        )
                    }
                )
                .background(
                    // Measure intrinsic (full) height
                    Text(text)
                        .font(font)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .hidden()
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: IntrinsicHeightPreferenceKey.self,
                                    value: geometry.size.height
                                )
                            }
                        )
                )
                .onPreferenceChange(TruncatedHeightPreferenceKey.self) { height in
                    truncatedHeight = height
                    updateTruncationState()
                }
                .onPreferenceChange(IntrinsicHeightPreferenceKey.self) { height in
                    intrinsicHeight = height
                    updateTruncationState()
                }
                .animation(Theme.Animation.standard, value: isExpanded)
                .accessibilityIdentifier("ExpandableText_\(lineLimit)Lines")

            if isTruncated {
                Button {
                    withAnimation(Theme.Animation.standard) {
                        isExpanded.toggle()
                    }
                } label: {
                    Text(isExpanded ? "Less" : "More")
                        .font(Theme.Typography.captionMedium)
                        .foregroundStyle(moreButtonColor)
                }
                .accessibilityIdentifier(isExpanded ? "LessButton" : "MoreButton")
                .accessibilityHint(isExpanded ? "Collapse text" : "Expand text to read more")
            }
        }
    }

    private func updateTruncationState() {
        let tolerance: CGFloat = 1.0
        isTruncated = intrinsicHeight > truncatedHeight + tolerance && !isExpanded

        if isExpanded && intrinsicHeight > 0 {
            isTruncated = true
        }
    }
}

// MARK: - Preference Keys

private struct TruncatedHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct IntrinsicHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Preview

#Preview("Short text") {
    ExpandableTextView(
        text: "Quick stretch",
        lineLimit: 3
    )
    .padding()
    .background(Color.background)
}

#Preview("Long description") {
    ExpandableTextView(
        text: "Gently tilt your head to the right, bringing your ear toward your shoulder. Hold for 15 seconds, feeling the stretch along the left side of your neck. Return to center and repeat on the opposite side. Keep your shoulders relaxed throughout.",
        lineLimit: 3
    )
    .padding()
    .background(Color.background)
}
