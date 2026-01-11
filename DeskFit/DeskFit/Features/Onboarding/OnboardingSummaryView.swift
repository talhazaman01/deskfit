import SwiftUI

struct OnboardingSummaryView: View {
    let goal: UserGoal?
    let focusAreas: Set<FocusArea>
    let dailyTimeMinutes: Int
    let reminderFrequency: ReminderFrequency
    let workStartMinutes: Int
    let workEndMinutes: Int
    let hasPersonalInfo: Bool
    let onStartReset: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Theme.Spacing.xxl) {
                    headerSection

                    summaryCards
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.top, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.xxl)
            }

            ctaSection
        }
        .background(Color.background)
        .onAppear {
            AnalyticsService.shared.track(.onboardingSummaryViewed)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark.seal.fill")
                    .font(Theme.Typography.stat)
                    .foregroundStyle(.appPrimary)
            }

            Text("Your plan is ready")
                .font(Theme.Typography.largeTitle)
                .foregroundStyle(.textPrimary)

            Text("Here's what we've personalized for you")
                .font(Theme.Typography.subtitle)
                .foregroundStyle(.textSecondary)

            // Personalized badge - shown if user provided personal info
            if hasPersonalInfo {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "sparkles")
                        .font(Theme.Typography.captionMedium)

                    Text("Personalized for you")
                        .font(Theme.Typography.captionMedium)
                }
                .foregroundStyle(.appPrimary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(
                    Capsule()
                        .fill(Color.appPrimary.opacity(0.1))
                )
            }
        }
        .padding(.top, Theme.Spacing.lg)
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        VStack(spacing: Theme.Spacing.md) {
            SummaryRow(
                icon: goal?.icon ?? "target",
                title: "Goal",
                value: goal?.displayName ?? "Not set"
            )

            SummaryRow(
                icon: "figure.flexibility",
                title: "Focus areas",
                value: focusAreasText
            )

            SummaryRow(
                icon: "clock",
                title: "Time per break",
                value: "\(dailyTimeMinutes) min"
            )

            SummaryRow(
                icon: "bell",
                title: "Reminders",
                value: reminderFrequency.displayName
            )

            SummaryRow(
                icon: "calendar",
                title: "Work hours",
                value: workHoursText
            )
        }
    }

    private var focusAreasText: String {
        if focusAreas.isEmpty {
            return "Not set"
        }
        let names = focusAreas.map { $0.displayName }
        if names.count <= 2 {
            return names.joined(separator: ", ")
        }
        return "\(names[0]), \(names[1]) +\(names.count - 2)"
    }

    private var workHoursText: String {
        let startHour = workStartMinutes / 60
        let endHour = workEndMinutes / 60
        let startFormatted = formatHour(startHour)
        let endFormatted = formatHour(endHour)
        return "\(startFormatted) - \(endFormatted)"
    }

    private func formatHour(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour < 12 ? "AM" : "PM"
        return "\(h) \(ampm)"
    }

    // MARK: - CTA Section

    private var ctaSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("Experience a quick reset before you start")
                .font(Theme.Typography.caption)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)

            PrimaryButton(title: "Try your first reset (60s)") {
                onStartReset()
            }
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.bottom, Theme.Spacing.bottomArea)
        .padding(.top, Theme.Spacing.lg)
        .background(
            Color.background
                .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
        )
    }
}

// MARK: - Summary Row Component

private struct SummaryRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.surface)
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.appPrimary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)

                Text(value)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)
            }

            Spacer()
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.surface)
        )
    }
}

#Preview("Without personalization") {
    OnboardingSummaryView(
        goal: .reduceStiffness,
        focusAreas: [.neck, .shoulders, .lowerBack],
        dailyTimeMinutes: 5,
        reminderFrequency: .every2Hours,
        workStartMinutes: 540,
        workEndMinutes: 1020,
        hasPersonalInfo: false,
        onStartReset: {}
    )
}

#Preview("With personalization") {
    OnboardingSummaryView(
        goal: .improvePosture,
        focusAreas: [.neck, .shoulders, .upperBack],
        dailyTimeMinutes: 5,
        reminderFrequency: .hourly,
        workStartMinutes: 480,
        workEndMinutes: 1020,
        hasPersonalInfo: true,
        onStartReset: {}
    )
}
