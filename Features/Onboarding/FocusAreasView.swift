import SwiftUI

struct FocusAreasView: View {
    @Binding var selectedAreas: Set<FocusArea>

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title section
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Where do you feel stiffness?")
                    .font(Theme.Typography.largeTitle)
                    .foregroundStyle(.textPrimary)

                Text("Select all that apply.")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, Theme.Spacing.xxl)

            Spacer()

            // Grid of focus areas
            LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                ForEach(FocusArea.allCases) { area in
                    FocusAreaChip(
                        area: area,
                        isSelected: selectedAreas.contains(area)
                    ) {
                        withAnimation(Theme.Animation.spring) {
                            if selectedAreas.contains(area) {
                                selectedAreas.remove(area)
                            } else {
                                selectedAreas.insert(area)
                            }
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

#Preview {
    FocusAreasView(selectedAreas: .constant([.neck, .shoulders]))
}
