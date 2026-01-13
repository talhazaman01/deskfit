import SwiftUI

struct StiffnessTimeView: View {
    @Binding var selectedStiffnessTimes: Set<StiffnessTime>

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
                                onTap: {
                                    selectedStiffnessTimes = StiffnessTime.toggle(time, in: selectedStiffnessTimes)
                                }
                            )
                        }

                        // "All day" option at bottom (mutually exclusive with individual times)
                        StiffnessTimeCard(
                            time: .allDay,
                            isSelected: selectedStiffnessTimes.contains(.allDay),
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
    let onTap: () -> Void

    /// Computed styling based on selection state
    private var iconBackgroundColor: Color {
        isSelected ? Color.appTeal.opacity(0.2) : Color.cardBackground
    }

    private var iconForegroundColor: Color {
        isSelected ? .appTeal : .textSecondary
    }

    private var borderColor: Color {
        isSelected ? Color.appTeal : Color.borderDefault
    }

    private var checkmarkColor: Color {
        isSelected ? .appTeal : .textSecondary
    }

    var body: some View {
        Button(action: onTap) {
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
                        .foregroundStyle(.textPrimary)

                    Text(time.description)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.textSecondary)
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
    }
}

#Preview {
    StiffnessTimeView(selectedStiffnessTimes: .constant([.midday, .evening]))
}
