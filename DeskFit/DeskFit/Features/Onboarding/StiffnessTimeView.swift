import SwiftUI

struct StiffnessTimeView: View {
    @Binding var selectedStiffnessTimes: Set<StiffnessTime>

    /// Whether "All day" is selected
    private var isAllDaySelected: Bool {
        selectedStiffnessTimes.contains(.allDay)
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
                        // Individual time options (morning, midday, evening) - shown first
                        ForEach(StiffnessTime.individualCases) { time in
                            StiffnessTimeCard(
                                time: time,
                                isSelected: selectedStiffnessTimes.contains(time),
                                isDisabled: isAllDaySelected,
                                onTap: {
                                    selectedStiffnessTimes = StiffnessTime.toggle(time, in: selectedStiffnessTimes)
                                }
                            )
                        }

                        // "All day" option at bottom (mutually exclusive with individual times)
                        StiffnessTimeCard(
                            time: .allDay,
                            isSelected: isAllDaySelected,
                            isDisabled: false,
                            onTap: {
                                selectedStiffnessTimes = StiffnessTime.toggle(.allDay, in: selectedStiffnessTimes)
                            }
                        )
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
    let isDisabled: Bool
    let onTap: () -> Void

    /// Computed styling based on selection and disabled state
    private var iconBackgroundColor: Color {
        if isDisabled {
            return Color.cardBackground.opacity(0.5)
        }
        return isSelected ? Color.appTeal.opacity(0.2) : Color.cardBackground
    }

    private var iconForegroundColor: Color {
        if isDisabled {
            return .textSecondary.opacity(0.4)
        }
        return isSelected ? .appTeal : .textSecondary
    }

    private var titleColor: Color {
        if isDisabled {
            return .textPrimary.opacity(0.4)
        }
        return .textPrimary
    }

    private var subtitleColor: Color {
        if isDisabled {
            return .textSecondary.opacity(0.4)
        }
        return .textSecondary
    }

    private var borderColor: Color {
        if isDisabled {
            return Color.clear
        }
        return isSelected ? Color.appTeal : Color.borderDefault
    }

    private var checkmarkColor: Color {
        if isDisabled {
            return .textSecondary.opacity(0.3)
        }
        return isSelected ? .appTeal : .textSecondary
    }

    var body: some View {
        Button(action: {
            if !isDisabled {
                onTap()
            }
        }) {
            HStack(spacing: Theme.Spacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 48, height: 48)

                    Image(systemName: time.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(iconForegroundColor)
                }

                // Text content
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(time.displayName)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(titleColor)

                    Text(time.description)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(subtitleColor)
                }

                Spacer()

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(checkmarkColor)
            }
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.large)
                            .strokeBorder(borderColor, lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .allowsHitTesting(!isDisabled)
    }
}

#Preview {
    StiffnessTimeView(selectedStiffnessTimes: .constant([.midday, .evening]))
}
