import SwiftUI

struct DateOfBirthView: View {
    @Binding var dateOfBirth: Date
    @Binding var hasSetDateOfBirth: Bool

    /// Minimum date: 100 years ago
    private var minimumDate: Date {
        Calendar.current.date(byAdding: .year, value: -100, to: Date()) ?? Date()
    }

    /// Maximum date: 13 years ago (minimum age requirement)
    private var maximumDate: Date {
        Calendar.current.date(byAdding: .year, value: -13, to: Date()) ?? Date()
    }

    private var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title section
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("When were you born?")
                    .font(Theme.Typography.largeTitle)
                    .foregroundStyle(.textPrimary)

                Text("Used to tailor your plan. Not shared.")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, Theme.Spacing.xxl)

            Spacer()

            // Date picker
            VStack(spacing: Theme.Spacing.lg) {
                DatePicker(
                    "",
                    selection: $dateOfBirth,
                    in: minimumDate...maximumDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .onChange(of: dateOfBirth) { _, _ in
                    if !hasSetDateOfBirth {
                        withAnimation(Theme.Animation.spring) {
                            hasSetDateOfBirth = true
                        }
                    }
                }

                // Age confirmation badge
                if hasSetDateOfBirth {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.success)
                            .font(.system(size: 16, weight: .medium))

                        Text("\(age) years old")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(.textPrimary)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.vertical, Theme.Spacing.md)
                    .background(
                        Capsule()
                            .fill(Color.cardBackground)
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Previews

#Preview("Default - iPhone SE") {
    DateOfBirthView(
        dateOfBirth: .constant(Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()),
        hasSetDateOfBirth: .constant(false)
    )
    .previewDevice("iPhone SE (3rd generation)")
}

#Preview("Selected - iPhone SE") {
    DateOfBirthView(
        dateOfBirth: .constant(Calendar.current.date(byAdding: .year, value: -32, to: Date()) ?? Date()),
        hasSetDateOfBirth: .constant(true)
    )
    .previewDevice("iPhone SE (3rd generation)")
}

#Preview("Default - iPhone 15 Pro") {
    DateOfBirthView(
        dateOfBirth: .constant(Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()),
        hasSetDateOfBirth: .constant(false)
    )
    .previewDevice("iPhone 15 Pro")
}

#Preview("Selected - iPhone 15 Pro") {
    DateOfBirthView(
        dateOfBirth: .constant(Calendar.current.date(byAdding: .year, value: -28, to: Date()) ?? Date()),
        hasSetDateOfBirth: .constant(true)
    )
    .previewDevice("iPhone 15 Pro")
}

#Preview("Default - iPhone 15 Pro Max") {
    DateOfBirthView(
        dateOfBirth: .constant(Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()),
        hasSetDateOfBirth: .constant(false)
    )
    .previewDevice("iPhone 15 Pro Max")
}

#Preview("Selected - iPhone 15 Pro Max") {
    DateOfBirthView(
        dateOfBirth: .constant(Calendar.current.date(byAdding: .year, value: -45, to: Date()) ?? Date()),
        hasSetDateOfBirth: .constant(true)
    )
    .previewDevice("iPhone 15 Pro Max")
}
