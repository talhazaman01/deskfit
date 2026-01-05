import SwiftUI

struct HeightWeightView: View {
    @Binding var measurementUnit: MeasurementUnit
    @Binding var heightFeet: Int
    @Binding var heightInches: Int
    @Binding var heightCm: Int
    @Binding var weightLb: Int
    @Binding var weightKg: Int
    @Binding var hasEnteredHeight: Bool
    @Binding var hasEnteredWeight: Bool

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case heightCm
        case heightFeet
        case heightInches
        case weightLb
        case weightKg
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title section
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Your measurements")
                    .font(Theme.Typography.largeTitle)
                    .foregroundStyle(.textPrimary)

                Text("Optional. Helps personalize your experience.")
                    .font(Theme.Typography.subtitle)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, Theme.Spacing.xl)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Theme.Spacing.xl) {
                    // Unit toggle
                    unitToggle

                    // Height input
                    heightSection

                    // Weight input
                    weightSection
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.bottom, Theme.Spacing.xxl)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }

    // MARK: - Unit Toggle

    private var unitToggle: some View {
        HStack(spacing: 0) {
            ForEach(MeasurementUnit.allCases, id: \.self) { unit in
                Button {
                    withAnimation(Theme.Animation.spring) {
                        measurementUnit = unit
                    }
                    HapticsService.shared.light()
                } label: {
                    Text(unit == .metric ? "Metric" : "Imperial")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(measurementUnit == unit ? .textOnDark : .textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                .fill(measurementUnit == unit ? Color.cardSelected : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium + 4)
                .fill(Color.cardBackground)
        )
    }

    // MARK: - Height Section

    private var heightSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Height")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)

                Spacer()

                Text(measurementUnit.heightLabel)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textTertiary)
            }

            if measurementUnit == .metric {
                // Metric: cm input
                MeasurementInputField(
                    value: $heightCm,
                    placeholder: "170",
                    suffix: "cm",
                    range: 100...250,
                    onBeginEditing: { hasEnteredHeight = true }
                )
                .focused($focusedField, equals: .heightCm)
            } else {
                // Imperial: feet + inches
                HStack(spacing: Theme.Spacing.md) {
                    MeasurementInputField(
                        value: $heightFeet,
                        placeholder: "5",
                        suffix: "ft",
                        range: 3...8,
                        onBeginEditing: { hasEnteredHeight = true }
                    )
                    .focused($focusedField, equals: .heightFeet)

                    MeasurementInputField(
                        value: $heightInches,
                        placeholder: "7",
                        suffix: "in",
                        range: 0...11,
                        onBeginEditing: { hasEnteredHeight = true }
                    )
                    .focused($focusedField, equals: .heightInches)
                }
            }
        }
    }

    // MARK: - Weight Section

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Weight")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)

                Spacer()

                Text(measurementUnit.weightLabel)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textTertiary)
            }

            if measurementUnit == .metric {
                MeasurementInputField(
                    value: $weightKg,
                    placeholder: "70",
                    suffix: "kg",
                    range: 30...300,
                    onBeginEditing: { hasEnteredWeight = true }
                )
                .focused($focusedField, equals: .weightKg)
            } else {
                MeasurementInputField(
                    value: $weightLb,
                    placeholder: "150",
                    suffix: "lb",
                    range: 66...660,
                    onBeginEditing: { hasEnteredWeight = true }
                )
                .focused($focusedField, equals: .weightLb)
            }
        }
    }
}

// MARK: - Measurement Input Field

private struct MeasurementInputField: View {
    @Binding var value: Int
    let placeholder: String
    let suffix: String
    let range: ClosedRange<Int>
    var onBeginEditing: () -> Void = {}

    @State private var textValue: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            TextField(placeholder, text: $textValue)
                .keyboardType(.numberPad)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.center)
                .focused($isFocused)
                .onChange(of: isFocused) { _, focused in
                    if focused {
                        onBeginEditing()
                    }
                }
                .onChange(of: textValue) { _, newValue in
                    // Filter to digits only
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        textValue = filtered
                    }
                    // Update binding
                    if let intValue = Int(filtered) {
                        value = intValue
                    }
                }
                .onAppear {
                    if value > 0 {
                        textValue = String(value)
                    }
                }

            Text(suffix)
                .font(Theme.Typography.body)
                .foregroundStyle(.textSecondary)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .strokeBorder(isFocused ? Color.appTeal : Color.clear, lineWidth: 2)
                )
        )
    }
}

// MARK: - Previews

#Preview("Imperial - iPhone SE") {
    HeightWeightView(
        measurementUnit: .constant(.imperial),
        heightFeet: .constant(5),
        heightInches: .constant(7),
        heightCm: .constant(170),
        weightLb: .constant(150),
        weightKg: .constant(68),
        hasEnteredHeight: .constant(false),
        hasEnteredWeight: .constant(false)
    )
}

#Preview("Metric - iPhone SE") {
    HeightWeightView(
        measurementUnit: .constant(.metric),
        heightFeet: .constant(5),
        heightInches: .constant(7),
        heightCm: .constant(170),
        weightLb: .constant(150),
        weightKg: .constant(68),
        hasEnteredHeight: .constant(true),
        hasEnteredWeight: .constant(true)
    )
}

#Preview("Imperial - iPhone 15 Pro") {
    HeightWeightView(
        measurementUnit: .constant(.imperial),
        heightFeet: .constant(5),
        heightInches: .constant(10),
        heightCm: .constant(178),
        weightLb: .constant(165),
        weightKg: .constant(75),
        hasEnteredHeight: .constant(true),
        hasEnteredWeight: .constant(true)
    )
}

#Preview("Metric - iPhone 15 Pro") {
    HeightWeightView(
        measurementUnit: .constant(.metric),
        heightFeet: .constant(5),
        heightInches: .constant(7),
        heightCm: .constant(175),
        weightLb: .constant(150),
        weightKg: .constant(72),
        hasEnteredHeight: .constant(false),
        hasEnteredWeight: .constant(false)
    )
}

#Preview("Imperial - iPhone 15 Pro Max") {
    HeightWeightView(
        measurementUnit: .constant(.imperial),
        heightFeet: .constant(6),
        heightInches: .constant(2),
        heightCm: .constant(188),
        weightLb: .constant(190),
        weightKg: .constant(86),
        hasEnteredHeight: .constant(true),
        hasEnteredWeight: .constant(false)
    )
}

#Preview("Metric - iPhone 15 Pro Max") {
    HeightWeightView(
        measurementUnit: .constant(.metric),
        heightFeet: .constant(5),
        heightInches: .constant(7),
        heightCm: .constant(180),
        weightLb: .constant(150),
        weightKg: .constant(80),
        hasEnteredHeight: .constant(true),
        hasEnteredWeight: .constant(true)
    )
}
