import SwiftUI

struct WorkHoursView: View {
    @Binding var startMinutes: Int
    @Binding var endMinutes: Int

    var body: some View {
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
            .padding(.bottom, Theme.Spacing.xxl)

            Spacer()

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

            Spacer()
            Spacer()
        }
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
        endMinutes: .constant(1020)
    )
}
