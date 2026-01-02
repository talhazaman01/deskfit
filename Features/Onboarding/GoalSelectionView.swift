import SwiftUI

struct GoalSelectionView: View {
    @Binding var selectedGoal: UserGoal?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What's your main goal?")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("We'll personalize your experience")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(UserGoal.allCases) { goal in
                    GoalOptionCard(
                        goal: goal,
                        isSelected: selectedGoal == goal
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedGoal = goal
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

struct GoalOptionCard: View {
    let goal: UserGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.headline)
                    Text(goal.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.brandPrimary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isSelected ? Color.brandPrimary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
