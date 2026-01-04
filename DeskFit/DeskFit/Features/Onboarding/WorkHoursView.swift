import SwiftUI

struct WorkHoursView: View {
    @Binding var startMinutes: Int
    @Binding var endMinutes: Int
    @Binding var sedentaryHoursBucket: SedentaryHoursBucket?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Title section
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("When do you work?")
                        .font(Theme.Typography.largeTitle)
                        .foregroundStyle(.textPrimary)

                    Text("We'll only remind you during these hours.")
                        .font(Theme.Typography.subtitle)
                        .foregroundStyle(.textSecondary)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, Theme.Spacing.xl)

                // Time pickers
                VStack(spacing: Theme.Spacing.md) {
                    TimePickerRow(label: "Start", minutesSinceMidnight: $startMinutes)
                    TimePickerRow(label: "End", minutesSinceMidnight: $endMinutes)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)

                // Validation message
                if endMinutes <= startMinutes {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.warning)
                        Text("End time must be after start time")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.textSecondary)
                    }
                    .padding(.horizontal, Theme.Spacing.screenHorizontal)
                    .padding(.top, Theme.Spacing.md)
                }

                // Sedentary hours section
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Sedentary hours")
                        .font(Theme.Typography.title)
                        .foregroundStyle(.textPrimary)

                    Text("How many hours are you seated on an average day?")
                        .font(Theme.Typography.subtitle)
                        .foregroundStyle(.textSecondary)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.top, Theme.Spacing.xxl)
                .padding(.bottom, Theme.Spacing.lg)

                // Sedentary hours options
                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(SedentaryHoursBucket.allCases) { bucket in
                        SedentaryHoursCard(
                            label: bucket.displayName,
                            isSelected: sedentaryHoursBucket == bucket
                        ) {
                            withAnimation(Theme.Animation.spring) {
                                if sedentaryHoursBucket == bucket {
                                    sedentaryHoursBucket = nil
                                } else {
                                    sedentaryHoursBucket = bucket
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)

                Spacer(minLength: Theme.Spacing.xxl)
            }
            .padding(.top, Theme.Spacing.md)
        }
        .scrollIndicators(.hidden)
    }
}

struct SedentaryHoursCard: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.light()
            action()
        }) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? .textOnDark : .textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .fill(isSelected ? Color.cardSelected : Color.cardBackground)
                )
        }
        .buttonStyle(.plain)
    }
}

struct TimePickerRow: View {
    let label: String
    @Binding var minutesSinceMidnight: Int

    private var dateBinding: Binding<Date> {
        Binding(
            get: { Date.fromMinutesSinceMidnight(minutesSinceMidnight) },
            set: { minutesSinceMidnight = $0.minutesSinceMidnight }
        )
    }

    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Typography.option)
                .foregroundStyle(.textPrimary)

            Spacer()

            DatePicker(
                "",
                selection: dateBinding,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .tint(.appTeal)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .frame(height: Theme.Height.optionCard)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.cardBackground)
        )
    }
}

#Preview {
    WorkHoursView(
        startMinutes: .constant(540),
        endMinutes: .constant(1020),
        sedentaryHoursBucket: .constant(nil)
    )
}
