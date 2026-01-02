import SwiftUI

struct FocusAreasView: View {
    @Binding var selectedAreas: Set<FocusArea>

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Where do you feel stiffness?")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Select all that apply")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(FocusArea.allCases) { area in
                    FocusAreaChip(
                        area: area,
                        isSelected: selectedAreas.contains(area)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            if selectedAreas.contains(area) {
                                selectedAreas.remove(area)
                            } else {
                                selectedAreas.insert(area)
                            }
                            HapticsService.shared.light()
                        }
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
            Spacer()
        }
        .padding()
    }
}
