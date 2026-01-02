import SwiftUI

struct SessionCardView: View {
    let session: PlannedSession
    let isLocked: Bool
    let onTap: () -> Void

    private var exercises: [Exercise] {
        ExerciseService.shared.getExercises(ids: session.exerciseIds)
    }

    private var focusAreas: [String] {
        Array(Set(exercises.flatMap { $0.focusAreas })).prefix(3).map { $0 }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(session.isCompleted ? Color.success.opacity(0.2) : Color.brandPrimary.opacity(0.1))
                        .frame(width: 48, height: 48)

                    if session.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.success)
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                    } else {
                        Image(systemName: session.type.icon)
                            .foregroundStyle(.brandPrimary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(.headline)
                        .foregroundStyle(isLocked ? .secondary : .primary)

                    HStack(spacing: 8) {
                        Text(session.durationSeconds.formattedMinutes)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .foregroundStyle(.secondary)

                        HStack(spacing: 4) {
                            ForEach(focusAreas, id: \.self) { area in
                                if let focusArea = FocusArea(rawValue: area) {
                                    Image(systemName: focusArea.icon)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Spacer()

                if isLocked {
                    Text("PRO")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.brandPrimary)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                } else if !session.isCompleted {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondaryBackground)
            )
            .opacity(session.isCompleted ? 0.7 : 1)
        }
        .buttonStyle(.plain)
        .disabled(session.isCompleted)
    }
}
