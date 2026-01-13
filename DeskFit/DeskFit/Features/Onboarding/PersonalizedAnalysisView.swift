import SwiftUI

/// Personalized posture analysis screen shown before the 7-day plan reveal.
/// Displays insights, risk factors, and recommendations based on onboarding answers.
struct PersonalizedAnalysisView: View {
    let report: AnalysisReport
    let onBuildPlan: () -> Void
    let onEditAnswers: (() -> Void)?

    @State private var hasAppeared = false

    init(
        report: AnalysisReport,
        onBuildPlan: @escaping () -> Void,
        onEditAnswers: (() -> Void)? = nil
    ) {
        self.report = report
        self.onBuildPlan = onBuildPlan
        self.onEditAnswers = onEditAnswers
    }

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Theme.Spacing.xl) {
                    // Header
                    headerSection
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)

                    // Score card
                    scoreCard
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)

                    // Insight cards
                    insightsSection
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)

                    // Focus areas
                    if !report.focusAreas.isEmpty {
                        focusAreasSection
                            .opacity(hasAppeared ? 1 : 0)
                            .offset(y: hasAppeared ? 0 : 20)
                    }

                    // What we'll do this week
                    weeklyActionsSection
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)

                    // Disclaimers
                    disclaimersSection
                        .opacity(hasAppeared ? 1 : 0)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.top, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.lg)
            }

            // CTA section
            ctaSection
        }
        .background(Color.appBackground)
        .onAppear {
            // Track analytics
            AnalyticsService.shared.track(.analysisViewed(
                score: report.score.value,
                category: report.score.category.rawValue,
                insightCount: report.insights.count
            ))

            // Track each insight
            for insight in report.insights {
                AnalyticsService.shared.track(.analysisInsightRendered(tags: insight.tags))
            }

            // Animate appearance
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                hasAppeared = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text("Your posture snapshot")
                .font(Theme.Typography.largeTitle)
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.center)

            Text("Based on your answers, here's what we'll target this week.")
                .font(Theme.Typography.subtitle)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Score Card

    private var scoreCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Score label
            Text("Stiffness & Sitting Load")
                .font(Theme.Typography.caption)
                .foregroundStyle(.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            // Score value
            HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.xs) {
                Text("\(report.score.value)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreColor)

                Text("/ 100")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textTertiary)
            }

            // Category badge
            Text(report.score.category.displayName)
                .font(Theme.Typography.caption)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.textOnAccent)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.xs)
                .background(
                    Capsule()
                        .fill(scoreColor)
                )

            // Category description
            Text(report.score.category.description)
                .font(Theme.Typography.subtitle)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Theme.Spacing.xs)
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.cardBackground)
        )
    }

    private var scoreColor: Color {
        switch report.score.category {
        case .low: return .appTeal
        case .moderate: return .streakFlame
        case .elevated: return .appCoral
        }
    }

    // MARK: - Insights Section

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("What we found")
                .font(Theme.Typography.headline)
                .foregroundStyle(.textPrimary)

            VStack(spacing: Theme.Spacing.md) {
                ForEach(Array(report.insights.enumerated()), id: \.element.id) { index, insight in
                    InsightCardView(insight: insight)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(
                            .easeOut(duration: 0.4).delay(0.2 + Double(index) * 0.1),
                            value: hasAppeared
                        )
                }
            }
        }
    }

    // MARK: - Focus Areas Section

    private var focusAreasSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Focus areas")
                .font(Theme.Typography.headline)
                .foregroundStyle(.textPrimary)

            FlowLayout(spacing: Theme.Spacing.sm) {
                ForEach(report.focusAreas, id: \.self) { area in
                    FocusAreaPill(text: area)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Weekly Actions Section

    private var weeklyActionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("What we'll do this week")
                .font(Theme.Typography.headline)
                .foregroundStyle(.textPrimary)

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                ForEach(report.weeklyActions, id: \.self) { action in
                    HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.appTeal)

                        Text(action)
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

    // MARK: - Disclaimers Section

    private var disclaimersSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            ForEach(report.disclaimers, id: \.self) { disclaimer in
                Text(disclaimer)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Theme.Spacing.md)
    }

    // MARK: - CTA Section

    private var ctaSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            PrimaryButton(title: "Build My 7-Day Plan") {
                AnalyticsService.shared.track(.analysisCtaTapped)
                onBuildPlan()
            }

            if let onEditAnswers = onEditAnswers {
                Button {
                    onEditAnswers()
                } label: {
                    Text("Edit my answers")
                        .font(Theme.Typography.subtitle)
                        .foregroundStyle(.textSecondary)
                }
                .padding(.vertical, Theme.Spacing.sm)
            }
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.bottom, Theme.Spacing.bottomArea)
    }
}

// MARK: - Insight Card View

private struct InsightCardView: View {
    let insight: InsightCard

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Header with icon and title
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: insight.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(severityColor)
                    .frame(width: 24, height: 24)

                Text(insight.title)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)

                Spacer()

                // Severity indicator
                SeverityBadge(severity: insight.severity)
            }

            // Body text
            Text(insight.body)
                .font(Theme.Typography.subtitle)
                .foregroundStyle(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            // Action line
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.appTeal)

                Text(insight.actionLabel)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.appTeal)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .stroke(severityColor.opacity(0.3), lineWidth: 1)
        )
    }

    private var severityColor: Color {
        switch insight.severity {
        case .low: return .appTeal
        case .medium: return .streakFlame
        case .high: return .appCoral
        }
    }
}

// MARK: - Severity Badge

private struct SeverityBadge: View {
    let severity: Severity

    var body: some View {
        Text(severity.displayName)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
    }

    private var foregroundColor: Color {
        switch severity {
        case .low: return .appTeal
        case .medium: return .streakFlame
        case .high: return .appCoral
        }
    }

    private var backgroundColor: Color {
        foregroundColor.opacity(0.15)
    }
}

// MARK: - Focus Area Pill

private struct FocusAreaPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Theme.Typography.caption)
            .fontWeight(.medium)
            .foregroundStyle(.textPrimary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                Capsule()
                    .fill(Color.cardBackground)
            )
    }
}

// MARK: - Flow Layout (for Focus Area pills)

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.bounds
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var bounds: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth, currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing

                bounds.width = max(bounds.width, currentX - spacing)
                bounds.height = currentY + lineHeight
            }
        }
    }
}

// MARK: - Previews

#Preview("Elevated Score") {
    PersonalizedAnalysisView(
        report: .mockElevatedScore,
        onBuildPlan: {},
        onEditAnswers: {}
    )
}

#Preview("Moderate Score") {
    PersonalizedAnalysisView(
        report: .mockModerateScore,
        onBuildPlan: {},
        onEditAnswers: {}
    )
}

#Preview("Low Score") {
    PersonalizedAnalysisView(
        report: .mockLowScore,
        onBuildPlan: {},
        onEditAnswers: nil
    )
}
