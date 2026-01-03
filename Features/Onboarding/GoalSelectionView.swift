import SwiftUI

struct GoalSelectionView: View {
    @Binding var selectedGoal: UserGoal?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title section
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("What is your goal?")
                    .font(Theme.Typography.largeTitle)
                    .foregroundStyle(.textPrimary)

                Text("This helps us create your personalized plan.")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, Theme.Spacing.xxl)

            Spacer()

            // Options
            VStack(spacing: Theme.Spacing.md) {
                ForEach(UserGoal.allCases) { goal in
                    OptionCard(
                        title: goal.displayName,
                        subtitle: goal.description,
                        isSelected: selectedGoal == goal
                    ) {
                        withAnimation(Theme.Animation.spring) {
                            selectedGoal = goal
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
    GoalSelectionView(selectedGoal: .constant(.reduceStiffness))
}
