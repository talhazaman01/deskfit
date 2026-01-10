import SwiftUI
import SwiftData

// MARK: - Today's Insight Section

/// A section displaying personalized daily insights on the Home tab.
struct TodayInsightSection: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyPlan.date, order: .reverse) private var plans: [DailyPlan]
    @EnvironmentObject var progressStore: ProgressStore

    @State private var insights: [DailyInsight] = []

    private var profile: UserProfile? { profiles.first }

    private var todaysPlan: DailyPlan? {
        plans.first { Calendar.current.isDateInToday($0.date) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Section header
            Text("Today's Insight")
                .font(Theme.Typography.title)
                .foregroundStyle(.textPrimary)

            // Insight cards
            if insights.isEmpty {
                // Loading state
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .fill(Color.cardBackground)
                    .frame(height: 120)
                    .overlay(
                        ProgressView()
                    )
            } else {
                ForEach(insights) { insight in
                    TodayInsightCard(insight: insight)
                }
            }
        }
        .onAppear {
            loadInsights()
        }
    }

    private func loadInsights() {
        let snapshot = profile.map { OnboardingProfileSnapshot.from(profile: $0) }

        Task { @MainActor in
            insights = InsightEngine.shared.getTodaysInsights(
                profile: snapshot,
                progressSummary: progressStore.currentSummary,
                todaysPlan: todaysPlan
            )
        }
    }
}

// MARK: - Today Insight Card

/// A single insight card with icon, title, body, and optional badge/CTA.
struct TodayInsightCard: View {
    let insight: DailyInsight

    @State private var hasAppeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Header row
            HStack(spacing: Theme.Spacing.sm) {
                // Icon
                Image(systemName: insight.category.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.appTeal)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color.appTeal.opacity(0.15))
                    )

                // Title
                Text(insight.title)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)
                    .lineLimit(2)

                Spacer()

                // Badge (optional)
                if let badge = insight.badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.appTeal)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.appTeal.opacity(0.15))
                        )
                }
            }

            // Body text
            Text(insight.body)
                .font(Theme.Typography.body)
                .foregroundStyle(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(4)

            // CTA (optional)
            if let ctaText = insight.ctaText {
                HStack(spacing: Theme.Spacing.xs) {
                    Text(ctaText)
                        .font(Theme.Typography.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.appTeal)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.appTeal)
                }
                .padding(.top, Theme.Spacing.xs)
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.cardBackground)
        )
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                hasAppeared = true
            }
        }
    }
}

// MARK: - Compact Insight Card

/// A more compact version of the insight card for secondary insights.
struct CompactInsightCard: View {
    let insight: DailyInsight

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Icon
            Image(systemName: insight.category.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.appTeal)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(Color.appTeal.opacity(0.15))
                )

            // Content
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(insight.title)
                    .font(Theme.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)

                Text(insight.body)
                    .font(.system(size: 12))
                    .foregroundStyle(.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            // Badge
            if let badge = insight.badge {
                Text(badge)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.appTeal)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color.appTeal.opacity(0.15))
                    )
            }
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.cardBackground)
        )
    }
}

// MARK: - Previews

#Preview("Today's Insight Section") {
    ScrollView {
        TodayInsightSection()
            .padding()
    }
    .background(Color.appBackground)
    .environmentObject(ProgressStore.shared)
}

#Preview("Single Insight Card") {
    TodayInsightCard(
        insight: DailyInsight(
            category: .painSpecific,
            title: "Neck Relief Focus",
            body: "Your neck discomfort may be connected to 6-8 hours of sitting. Today's resets target this area with gentle mobility exercises that can help reduce tension buildup.",
            badge: "Personalized",
            ctaText: "Start your first reset"
        )
    )
    .padding()
    .background(Color.appBackground)
}

#Preview("Compact Insight Card") {
    VStack(spacing: 12) {
        CompactInsightCard(
            insight: DailyInsight(
                category: .progressTip,
                title: "You're on a 5-day streak!",
                body: "Consistency is building healthy movement habits.",
                badge: "On Fire"
            )
        )

        CompactInsightCard(
            insight: DailyInsight(
                category: .motivational,
                title: "Small Steps, Big Impact",
                body: "Just 5 minutes of movement can help shift how your body feels."
            )
        )
    }
    .padding()
    .background(Color.appBackground)
}
