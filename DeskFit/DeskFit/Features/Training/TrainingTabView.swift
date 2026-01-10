import SwiftUI
import SwiftData

// MARK: - Training Tab View

/// Training tab with Plan and Library segments.
struct TrainingTabView: View {
    @ObservedObject var sessionCoordinator: TrainingSessionCoordinator

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Query private var profiles: [UserProfile]
    @Query private var weeklyPlans: [WeeklyPlan]

    @State private var selectedSegment: TrainingSegment = .plan

    private var profile: UserProfile? { profiles.first }

    private var currentWeeklyPlan: WeeklyPlan? {
        weeklyPlans.first { plan in
            let calendar = Calendar.current
            let weekStart = plan.weekStartDate
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            return Date() >= weekStart && Date() <= weekEnd
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Segmented Control
            Picker("", selection: $selectedSegment) {
                ForEach(TrainingSegment.allCases) { segment in
                    Text(segment.title).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, Theme.Spacing.md)

            // Content
            switch selectedSegment {
            case .plan:
                PlanView(weeklyPlan: currentWeeklyPlan, profile: profile, sessionCoordinator: sessionCoordinator)
            case .library:
                LibraryView()
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Training")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            AnalyticsService.shared.track(.tabOpened(name: "training"))
            generatePlanIfNeeded()
        }
    }

    private func generatePlanIfNeeded() {
        guard let profile = profile, currentWeeklyPlan == nil else { return }
        let _ = PlanGeneratorService.shared.getOrCreateWeeklyPlan(context: modelContext, profile: profile)
    }
}

// MARK: - Training Segment

enum TrainingSegment: String, CaseIterable, Identifiable {
    case plan
    case library

    var id: String { rawValue }

    var title: String {
        switch self {
        case .plan: return "Plan"
        case .library: return "Library"
        }
    }
}

// MARK: - Plan View

struct PlanView: View {
    let weeklyPlan: WeeklyPlan?
    let profile: UserProfile?
    @ObservedObject var sessionCoordinator: TrainingSessionCoordinator

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var entitlementStore: EntitlementStore

    private var todayDayIndex: Int {
        guard let plan = weeklyPlan else { return 0 }
        let calendar = Calendar.current
        return min(6, max(0, calendar.dateComponents([.day], from: plan.weekStartDate, to: Date()).day ?? 0))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                // Quick Reset (always available)
                quickResetCard

                // 7-Day Plan Overview
                weekOverviewSection

                // Today's Sessions
                if let todayPlan = weeklyPlan?.plan(for: todayDayIndex) {
                    todaySessionsSection(todayPlan)
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.bottomArea)
        }
    }

    // MARK: - Quick Reset Card

    @ViewBuilder
    private var quickResetCard: some View {
        Button {
            startQuickReset()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Quick Reset")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.textPrimary)

                    Text("2 min • Instant relief for desk tension")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.textSecondary)
                }

                Spacer()

                Image(systemName: "bolt.fill")
                    .font(.title2)
                    .foregroundStyle(.appTeal)
            }
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .fill(Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Week Overview

    @ViewBuilder
    private var weekOverviewSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Your 7-Day Plan")
                .font(Theme.Typography.headline)
                .foregroundStyle(.textPrimary)

            if let plan = weeklyPlan {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.Spacing.sm) {
                        ForEach(0..<7, id: \.self) { dayIndex in
                            DayCard(
                                dayPlan: plan.plan(for: dayIndex),
                                dayIndex: dayIndex,
                                isToday: dayIndex == todayDayIndex,
                                isLocked: !FeatureGate.canAccessPlanDay(dayIndex: dayIndex),
                                onTap: {
                                    if FeatureGate.canAccessPlanDay(dayIndex: dayIndex) {
                                        AnalyticsService.shared.track(.planDayOpened(dayIndex: dayIndex))
                                    } else {
                                        appState.presentPaywall(source: "plan_day_\(dayIndex)")
                                        AnalyticsService.shared.track(.upgradeTapped(source: "plan_day"))
                                    }
                                }
                            )
                        }
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            }

            // Upgrade prompt for free users
            if !entitlementStore.isPro {
                upgradePrompt
            }
        }
    }

    @ViewBuilder
    private var upgradePrompt: some View {
        Button {
            appState.presentPaywall(source: "plan_upgrade")
            AnalyticsService.shared.track(.upgradeTapped(source: "plan_upgrade"))
        } label: {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.textSecondary)
                Text("Unlock full 7-day plan")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)
                Spacer()
                Text("Go Pro")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.appTeal)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .stroke(Color.divider, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Today's Sessions

    @ViewBuilder
    private func todaySessionsSection(_ dayPlan: DayPlanItem) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Today's Sessions")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)

                Spacer()

                Text(dayPlan.focusLabel)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textSecondary)
            }

            ForEach(Array(dayPlan.sessions.enumerated()), id: \.element.id) { index, session in
                let isLocked = !FeatureGate.canAccessSession(sessionIndex: index, forDayIndex: todayDayIndex)

                SessionRow(
                    session: session,
                    isLocked: isLocked,
                    onTap: {
                        if isLocked {
                            appState.presentPaywall(source: "session_\(index)")
                            AnalyticsService.shared.track(.upgradeTapped(source: "training_session"))
                        } else {
                            startSession(session)
                        }
                    }
                )
            }
        }
    }

    // MARK: - Actions

    private func startQuickReset() {
        AnalyticsService.shared.track(.quickResetStarted(source: "training"))

        // Create a quick 2-minute session with basic exercises
        let quickExercises = ExerciseService.shared.getExercises(
            forDuration: 120,
            focusAreas: profile?.focusAreas ?? ["neck", "shoulders"]
        )

        let session = PlannedSession(
            type: .midday,
            title: "Quick Reset",
            exerciseIds: quickExercises.map { $0.id },
            durationSeconds: 120
        )

        sessionCoordinator.startSession(session)
    }

    private func startSession(_ microSession: MicroSession) {
        let session = PlannedSession(
            type: microSession.sessionType,
            title: microSession.title,
            exerciseIds: microSession.exerciseIds,
            durationSeconds: microSession.durationSeconds
        )

        AnalyticsService.shared.track(.sessionStartedFromSource(
            sessionId: microSession.id.uuidString,
            source: "training"
        ))

        sessionCoordinator.startSession(session)
    }
}

// MARK: - Day Card

struct DayCard: View {
    let dayPlan: DayPlanItem?
    let dayIndex: Int
    let isToday: Bool
    let isLocked: Bool
    let onTap: () -> Void

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        guard let weekStart = calendar.date(from: components) else { return "Day \(dayIndex + 1)" }
        let date = calendar.date(byAdding: .day, value: dayIndex, to: weekStart)!
        return formatter.string(from: date)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Theme.Spacing.xs) {
                Text(dayName)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(isToday ? .textOnDark : .textSecondary)

                Text("Day \(dayIndex + 1)")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(isToday ? .textOnDark : .textPrimary)

                if let plan = dayPlan {
                    if plan.isFullyCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(isToday ? .textOnDark : .success)
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(isToday ? .textOnDark.opacity(0.7) : .textTertiary)
                    } else {
                        Text("\(plan.sessions.count) sessions")
                            .font(.system(size: 10))
                            .foregroundStyle(isToday ? .textOnDark.opacity(0.8) : .textTertiary)
                    }
                }
            }
            .frame(width: 70, height: 90)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(isToday ? Color.appTeal : Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: MicroSession
    let isLocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                // Status Icon
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: statusIcon)
                        .foregroundStyle(statusColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(session.title)
                        .font(Theme.Typography.body)
                        .foregroundStyle(isLocked ? .textTertiary : .textPrimary)

                    Text(session.displayDuration)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.textSecondary)
                }

                Spacer()

                if session.isCompleted {
                    Text("Done")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.success)
                } else if isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.textTertiary)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.textTertiary)
                }
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
        .disabled(session.isCompleted)
    }

    private var statusIcon: String {
        if session.isCompleted {
            return "checkmark"
        } else if isLocked {
            return "lock.fill"
        } else {
            return session.sessionType.icon
        }
    }

    private var statusColor: Color {
        if session.isCompleted {
            return .success
        } else if isLocked {
            return .textTertiary
        } else {
            return .appTeal
        }
    }
}

// MARK: - Library View

struct LibraryView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var entitlementStore: EntitlementStore

    @State private var selectedCategory: ExerciseCategory = .all
    @State private var exercises: [Exercise] = []

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.Spacing.sm) {
                        ForEach(ExerciseCategory.allCases) { category in
                            CategoryChip(
                                category: category,
                                isSelected: selectedCategory == category,
                                onTap: {
                                    selectedCategory = category
                                    loadExercises()
                                }
                            )
                        }
                    }
                }

                // Exercise List
                LazyVStack(spacing: Theme.Spacing.md) {
                    ForEach(exercises) { exercise in
                        ExerciseRow(exercise: exercise) {
                            AnalyticsService.shared.track(.exerciseViewed(
                                exerciseId: exercise.id,
                                source: "library"
                            ))
                            // TODO: Navigate to exercise detail
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.top, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.bottomArea)
        }
        .onAppear {
            AnalyticsService.shared.track(.libraryOpened)
            loadExercises()
        }
    }

    private func loadExercises() {
        if selectedCategory == .all {
            exercises = ExerciseService.shared.getAllExercises()
        } else {
            exercises = ExerciseService.shared.getExercises(for: [selectedCategory.focusArea])
        }
    }
}

// MARK: - Exercise Category

enum ExerciseCategory: String, CaseIterable, Identifiable {
    case all
    case neck
    case shoulders
    case upperBack
    case lowerBack
    case core
    case fullBody

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "All"
        case .neck: return "Neck"
        case .shoulders: return "Shoulders"
        case .upperBack: return "Upper Back"
        case .lowerBack: return "Lower Back"
        case .core: return "Core"
        case .fullBody: return "Full Body"
        }
    }

    var focusArea: String {
        switch self {
        case .all: return ""
        case .neck: return "neck"
        case .shoulders: return "shoulders"
        case .upperBack: return "upper_back"
        case .lowerBack: return "lower_back"
        case .core: return "core"
        case .fullBody: return "full_body"
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let category: ExerciseCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(category.displayName)
                .font(Theme.Typography.caption)
                .foregroundStyle(isSelected ? .textOnDark : .textPrimary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.appBlack : Color.cardBackground)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Exercise Row

struct ExerciseRow: View {
    let exercise: Exercise
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.md) {
                // Exercise Icon/Image placeholder
                RoundedRectangle(cornerRadius: Theme.Radius.small)
                    .fill(Color.cardBackground)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: exercise.iconName)
                            .font(.title2)
                            .foregroundStyle(.textSecondary)
                            .accessibilityLabel(exercise.iconAccessibilityLabel)
                    )

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(exercise.name)
                        .font(Theme.Typography.body)
                        .foregroundStyle(.textPrimary)

                    HStack(spacing: Theme.Spacing.sm) {
                        Text("\(exercise.durationSeconds / 60) min")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.textSecondary)

                        Text("•")
                            .foregroundStyle(.textTertiary)

                        Text(exercise.difficulty.capitalized)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.textTertiary)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TrainingTabView(sessionCoordinator: TrainingSessionCoordinator())
    }
    .environmentObject(AppState())
    .environmentObject(SubscriptionManager.shared)
}
