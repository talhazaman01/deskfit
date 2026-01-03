import SwiftUI

struct GenderSelectionView: View {
    @Binding var selectedGender: Gender?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title section
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("How do you identify?")
                    .font(Theme.Typography.largeTitle)
                    .foregroundStyle(.textPrimary)

                Text("Used for better recommendations. Optional.")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, Theme.Spacing.xxl)

            Spacer()

            // Options
            VStack(spacing: Theme.Spacing.md) {
                ForEach(Gender.allCases) { gender in
                    OptionCard(
                        title: gender.displayName,
                        icon: gender.icon,
                        isSelected: selectedGender == gender
                    ) {
                        withAnimation(Theme.Animation.spring) {
                            selectedGender = gender
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Previews

#Preview("None selected - iPhone SE") {
    GenderSelectionView(selectedGender: .constant(nil))
        .previewDevice("iPhone SE (3rd generation)")
}

#Preview("Female selected - iPhone SE") {
    GenderSelectionView(selectedGender: .constant(.female))
        .previewDevice("iPhone SE (3rd generation)")
}

#Preview("None selected - iPhone 15 Pro") {
    GenderSelectionView(selectedGender: .constant(nil))
        .previewDevice("iPhone 15 Pro")
}

#Preview("Male selected - iPhone 15 Pro") {
    GenderSelectionView(selectedGender: .constant(.male))
        .previewDevice("iPhone 15 Pro")
}

#Preview("None selected - iPhone 15 Pro Max") {
    GenderSelectionView(selectedGender: .constant(nil))
        .previewDevice("iPhone 15 Pro Max")
}

#Preview("Non-binary selected - iPhone 15 Pro Max") {
    GenderSelectionView(selectedGender: .constant(.nonBinary))
        .previewDevice("iPhone 15 Pro Max")
}
