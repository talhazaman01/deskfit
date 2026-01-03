import SwiftUI

struct StiffnessTimeView: View {
    @Binding var selectedStiffnessTime: StiffnessTime?
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("When does stiffness hit?")
                            .font(Theme.Typography.largeTitle)
                            .foregroundStyle(.textPrimary)

                        Text("We'll prioritize your resets for when you need them most")
                            .font(Theme.Typography.subtitle)
                            .foregroundStyle(.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.xl)

                    // Options
                    VStack(spacing: Theme.Spacing.md) {
                        ForEach(StiffnessTime.allCases) { time in
                            StiffnessTimeCard(
                                time: time,
                                isSelected: selectedStiffnessTime == time,
                                onTap: {
                                    selectedStiffnessTime = time
                                    // Auto-continue after selection for one-tap experience
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        onContinue()
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
            }
        }
        .background(Color.appBackground)
    }
}

struct StiffnessTimeCard: View {
    let time: StiffnessTime
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.appTeal.opacity(0.2) : Color.cardBackground)
                        .frame(width: 48, height: 48)

                    Image(systemName: time.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? .appTeal : .textSecondary)
                }

                // Text content
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(time.displayName)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.textPrimary)

                    Text(time.description)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.textSecondary)
                }

                Spacer()

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? .appTeal : .textSecondary)
            }
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.large)
                            .strokeBorder(isSelected ? Color.appTeal : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StiffnessTimeView(
        selectedStiffnessTime: .constant(.midday),
        onContinue: {}
    )
}
