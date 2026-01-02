import SwiftUI

struct TimePreferenceView: View {
    @Binding var selectedTime: Int

    private let options = [
        (value: 2, label: "2 min", description: "Quick resets"),
        (value: 5, label: "5 min", description: "Balanced"),
        (value: 10, label: "10 min", description: "Thorough")
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("How much time per break?")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("You'll get 3 breaks throughout the day")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(options, id: \.value) { option in
                    TimeOptionCard(
                        label: option.label,
                        description: option.description,
                        isSelected: selectedTime == option.value
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTime = option.value
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

struct TimeOptionCard: View {
    let label: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(label)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.brandPrimary.opacity(0.1) : Color.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isSelected ? Color.brandPrimary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
