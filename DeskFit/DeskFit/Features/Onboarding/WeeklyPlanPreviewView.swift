import SwiftUI

/// Displays the personalized 7-day plan preview at the end of onboarding.
/// Shows day-by-day breakdown with themes, focus areas, and session counts.
struct WeeklyPlanPreviewView: View {
    let planResult: PlanGenerationResult
    let onUnlockPlans: () -> Void
    let onContinueFree: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
                .padding(.top, Theme.Spacing.lg)

            // Scrollable content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Theme.Spacing.lg) {
                    // 7-day plan cards
                    dayCardsSection

                    // Why this fits you
                    whyThisFitsSection

                    // Progression promise
                    progressionPromiseSection
                }
                .padding(.vertical, Theme.Spacing.lg)
            }

            // CTAs
            ctaSection
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .background(Color.appBackground)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text("Your 7-Day Plan")
                .font(Theme.Typography.largeTitle)
                .foregroundStyle(.textPrimary)

            Text("Personalized based on your goals")
                .font(Theme.Typography.subtitle)
                .foregroundStyle(.textSecondary)
        }
    }

    // MARK: - Day Cards

    private var dayCardsSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            ForEach(planResult.plan.dailyPlans) { dayPlan in
                DayPlanCard(dayPlan: dayPlan)
            }
        }
    }

    // MARK: - Why This Fits

    private var whyThisFitsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Why this fits you")
                .font(Theme.Typography.headline)
                .foregroundStyle(.textPrimary)

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                ForEach(planResult.whyThisFits, id: \.self) { bullet in
                    HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.appTeal)

                        Text(bullet)
                            .font(Theme.Typography.body)
                            .foregroundStyle(.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.cardBackground)
        )
    }

    // MARK: - Progression Promise

    private var progressionPromiseSection: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 24))
                .foregroundStyle(.appTeal)

            Text(planResult.progressionPromise)
                .font(Theme.Typography.subtitle)
                .foregroundStyle(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .stroke(Color.appTeal.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - CTA Section

    private var ctaSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            PrimaryButton(title: "Unlock your plan") {
                onUnlockPlans()
            }

            Button {
                onContinueFree()
            } label: {
                Text("Continue free")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.vertical, Theme.Spacing.sm)
        }
        .padding(.bottom, Theme.Spacing.bottomArea)
    }
}

// MARK: - Day Plan Card

private struct DayPlanCard: View {
    let dayPlan: DayPlanItem

    private var dayNumber: Int {
        dayPlan.dayIndex + 1
    }

    private var sessionCount: Int {
        dayPlan.sessions.count
    }

    private var totalMinutes: Int {
        dayPlan.totalDurationMinutes
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Day number badge
            dayBadge

            // Day details
            VStack(alignment: .leading, spacing: 2) {
                Text(dayPlan.theme)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)

                Text(dayPlan.focusLabel)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)
            }

            Spacer()

            // Session info
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(sessionCount) \(sessionCount == 1 ? "session" : "sessions")")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)

                Text("\(totalMinutes) min")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.appTeal)
            }
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.cardBackground)
        )
    }

    private var dayBadge: some View {
        ZStack {
            Circle()
                .fill(dayPlan.dayIndex == 0 ? AppTheme.accent : AppTheme.accent.opacity(0.15))
                .frame(width: 44, height: 44)

            Text("\(dayNumber)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(dayPlan.dayIndex == 0 ? AppTheme.textOnAccent : AppTheme.accent)
        }
    }
}

// MARK: - Previews

#Preview("Weekly Plan Preview") {
    // Create mock data for preview
    let mockDailyPlans = (0..<7).map { dayIndex in
        DayPlanItem(
            dayIndex: dayIndex,
            sessions: [
                MicroSession(
                    title: "Morning Reset",
                    sessionType: .morning,
                    exerciseIds: ["ex1", "ex2"],
                    durationSeconds: 120
                ),
                MicroSession(
                    title: "Midday Refresh",
                    sessionType: .midday,
                    exerciseIds: ["ex3", "ex4"],
                    durationSeconds: 120
                )
            ],
            focusLabel: dayIndex % 2 == 0 ? "Neck & Shoulders" : "Upper Back & Hips",
            theme: ["Foundation", "Mobility", "Build Strength", "Recovery", "Foundation", "Mobility", "Active Recovery"][dayIndex]
        )
    }

    let mockSnapshot = OnboardingProfileSnapshot(
        goal: "reduce_stiffness",
        focusAreas: ["neck", "shoulders"],
        painAreas: [],
        postureIssues: [],
        stiffnessTimes: ["morning", "midday"],
        workType: "desk_home",
        sedentaryHoursBucket: "6_to_8",
        exerciseFrequency: nil,
        motivationLevel: nil,
        dailyTimeMinutes: 5,
        workStartMinutes: 540,
        workEndMinutes: 1020
    )

    let mockPlan = WeeklyPlan(
        dailyPlans: mockDailyPlans,
        profileSnapshot: mockSnapshot,
        weekStartDate: Date()
    )

    let mockResult = PlanGenerationResult(
        plan: mockPlan,
        whyThisFits: [
            "Targets your neck and shoulders with specific relief exercises",
            "2 quick sessions per day that fit your 5-minute window",
            "Timed for when you feel stiffest: morning and midday"
        ],
        progressionPromise: "Stick with it for a week and you'll start feeling the difference."
    )

    return WeeklyPlanPreviewView(
        planResult: mockResult,
        onUnlockPlans: {},
        onContinueFree: {}
    )
}
