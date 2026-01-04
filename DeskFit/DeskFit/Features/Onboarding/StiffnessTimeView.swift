import SwiftUI

struct StiffnessTimeView: View {
    @Binding var selectedStiffnessTimes: Set<StiffnessTime>

    /// Whether all individual times are selected
    private var isAllSelected: Bool {
        selectedStiffnessTimes.count == StiffnessTime.allCases.count
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("When does stiffness hit?")
                            .font(Theme.Typography.largeTitle)
                            .foregroundStyle(.textPrimary)

                        Text("Select all that apply — we'll prioritize your resets accordingly")
                            .font(Theme.Typography.subtitle)
                            .foregroundStyle(.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.xl)

                    // Options
                    VStack(spacing: Theme.Spacing.md) {
                        // "All day" option at top
                        AllDayCard(
                            isSelected: isAllSelected,
                            onTap: {
                                if isAllSelected {
                                    // Deselect all
                                    selectedStiffnessTimes.removeAll()
                                } else {
                                    // Select all
                                    selectedStiffnessTimes = Set(StiffnessTime.allCases)
                                }
                            }
                        )

                        // Individual time options
                        ForEach(StiffnessTime.allCases) { time in
                            StiffnessTimeCard(
                                time: time,
                                isSelected: selectedStiffnessTimes.contains(time),
                                onTap: {
                                    if selectedStiffnessTimes.contains(time) {
                                        selectedStiffnessTimes.remove(time)
                                    } else {
                                        selectedStiffnessTimes.insert(time)
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

struct AllDayCard: View {
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

                    Image(systemName: "clock.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? .appTeal : .textSecondary)
                }

                // Text content
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("All day")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.textPrimary)

                    Text("It varies throughout my workday")
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
    StiffnessTimeView(selectedStiffnessTimes: .constant([.midday, .evening]))
}
