import SwiftUI

struct SessionCardView: View {
    let session: PlannedSession
    let isLocked: Bool
    let lockReason: String?
    let onTap: () -> Void

    init(
        session: PlannedSession,
        isLocked: Bool,
        lockReason: String? = nil,
        onTap: @escaping () -> Void
    ) {
        self.session = session
        self.isLocked = isLocked
        self.lockReason = lockReason
        self.onTap = onTap
    }

    private var exercises: [Exercise] {
        ExerciseService.shared.getExercises(ids: session.exerciseIds)
    }

    private var focusAreas: [String] {
        Array(Set(exercises.flatMap { $0.focusAreas })).prefix(3).map { $0 }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Main content row
                HStack(spacing: Theme.Spacing.lg) {
                    // Icon circle
                    ZStack {
                        Circle()
                            .fill(session.isCompleted ? Color.success.opacity(0.2) : Color.appTeal.opacity(0.1))
                            .frame(width: 48, height: 48)

                        if session.isCompleted {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.success)
                        } else if isLocked {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.textSecondary)
                        } else {
                            Image(systemName: session.type.icon)
                                .foregroundStyle(.appTeal)
                        }
                    }

                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(session.title)
                            .font(Theme.Typography.headline)
                            .foregroundStyle(isLocked ? .textSecondary : .textPrimary)

                        HStack(spacing: Theme.Spacing.sm) {
                            Text(session.durationSeconds.formattedMinutes)
                                .font(Theme.Typography.caption)
                                .foregroundStyle(.textSecondary)

                            Text("•")
                                .foregroundStyle(.textSecondary)

                            HStack(spacing: Theme.Spacing.xs) {
                                ForEach(focusAreas, id: \.self) { area in
                                    if let focusArea = FocusArea(rawValue: area) {
                                        Image(systemName: focusArea.icon)
                                            .font(.caption2)
                                            .foregroundStyle(.textSecondary)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()

                    if isLocked {
                        Text("PRO")
                            .font(Theme.Typography.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(Color.appTeal)
                            .foregroundStyle(.textOnDark)
                            .clipShape(Capsule())
                    } else if !session.isCompleted {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.textSecondary)
                    }
                }

                // Lock reason (if locked and reason provided)
                if isLocked, let reason = lockReason {
                    Text(reason)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.textTertiary)
                        .padding(.top, Theme.Spacing.sm)
                        .padding(.leading, 48 + Theme.Spacing.lg) // Align with text
                }
            }
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .fill(Color.cardBackground)
            )
            .opacity(session.isCompleted ? 0.7 : 1)
        }
        .buttonStyle(.plain)
        .disabled(session.isCompleted)
    }
}
