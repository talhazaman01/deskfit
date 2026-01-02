import SwiftUI

struct WorkHoursView: View {
    @Binding var startMinutes: Int
    @Binding var endMinutes: Int

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("When do you work?")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("We'll only remind you during these hours")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 20) {
                TimePicker(label: "Start", minutesSinceMidnight: $startMinutes)
                TimePicker(label: "End", minutesSinceMidnight: $endMinutes)
            }
            .padding(.horizontal)

            if endMinutes <= startMinutes {
                Label("End time must be after start time", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct TimePicker: View {
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
                .font(.headline)

            Spacer()

            DatePicker(
                "",
                selection: dateBinding,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .tint(.brandPrimary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondaryBackground)
        )
    }
}
