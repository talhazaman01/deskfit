import SwiftUI

// MARK: - Theme Preview Gallery
// Visual QA tool to verify theme tokens work correctly in both Light and Dark modes

struct ThemePreviewGallery: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxl) {
                backgroundSection
                textSection
                cardSection
                selectionSection
                buttonSection
                statusSection
                progressSection
            }
            .padding(Theme.Spacing.screenHorizontal)
        }
        .deskFitScreenBackground()
    }

    // MARK: - Background Section

    private var backgroundSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader("Backgrounds")

            HStack(spacing: Theme.Spacing.md) {
                colorSwatch("App BG", AppTheme.appBackground)
                colorSwatch("Card BG", AppTheme.cardBackground)
                colorSwatch("Surface Alt", AppTheme.surfaceAlt)
            }
        }
    }

    // MARK: - Text Section

    private var textSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader("Text Tokens")

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Primary Text - Navy on light, White on dark")
                    .font(Theme.Typography.body)
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Secondary Text - 70%/75% opacity")
                    .font(Theme.Typography.body)
                    .foregroundStyle(AppTheme.textSecondary)

                Text("Tertiary Text - 50%/55% opacity")
                    .font(Theme.Typography.body)
                    .foregroundStyle(AppTheme.textTertiary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(AppTheme.cardBackground)
            )
        }
    }

    // MARK: - Card Section

    private var cardSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader("Card Styles")

            VStack(spacing: Theme.Spacing.md) {
                // Standard card
                HStack {
                    Image(systemName: "square.stack.3d.up")
                        .font(.title2)
                        .foregroundStyle(AppTheme.accent)

                    VStack(alignment: .leading) {
                        Text("Standard Card")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Uses cardBackground + shadow")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                }
                .deskFitCardStyle()
            }
        }
    }

    // MARK: - Selection Section

    private var selectionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader("Selection States")

            VStack(spacing: Theme.Spacing.md) {
                // Unselected row
                HStack {
                    Text("Unselected Option")
                        .font(Theme.Typography.option)
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .frame(height: Theme.Height.optionCard)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .fill(AppTheme.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .strokeBorder(AppTheme.strokeSubtle, lineWidth: 1)
                )

                // Selected row
                HStack {
                    Text("Selected Option")
                        .font(Theme.Typography.option)
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    SelectionCheckmark()
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .frame(height: Theme.Height.optionCard)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .fill(AppTheme.selectionFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .strokeBorder(AppTheme.selectionStroke, lineWidth: 2)
                )
            }

            // Contrast note
            Text("Selection: Celeste fill + Navy stroke (light) / Teal stroke (dark)")
                .font(Theme.Typography.caption)
                .foregroundStyle(AppTheme.textTertiary)
        }
    }

    // MARK: - Button Section

    private var buttonSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader("Buttons")

            VStack(spacing: Theme.Spacing.md) {
                // Primary button
                Button("Primary Action") {}
                    .buttonStyle(CelestePrimaryButtonStyle())

                // Secondary button
                Button("Secondary Action") {}
                    .buttonStyle(CelesteSecondaryButtonStyle())

                // Disabled button
                Button("Disabled Button") {}
                    .buttonStyle(CelestePrimaryButtonStyle(isEnabled: false))
                    .disabled(true)
            }
        }
    }

    // MARK: - Status Section

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader("Status Colors")

            HStack(spacing: Theme.Spacing.md) {
                statusPill("Success", AppTheme.success)
                statusPill("Warning", AppTheme.warning)
                statusPill("Danger", AppTheme.danger)
                statusPill("Flame", AppTheme.streakFlame)
            }
        }
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionHeader("Progress Ring")

            HStack(spacing: Theme.Spacing.xl) {
                CircularProgressView(progress: 0.65, size: 80)

                VStack(alignment: .leading) {
                    Text("Track: progressRingTrack")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("Fill: progressRingFill (accent teal)")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Theme.Typography.headline)
            .foregroundStyle(AppTheme.accent)
    }

    private func colorSwatch(_ name: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.strokeSubtle, lineWidth: 1)
                )

            Text(name)
                .font(.system(size: 10))
                .foregroundStyle(AppTheme.textTertiary)
        }
    }

    private func statusPill(_ name: String, _ color: Color) -> some View {
        Text(name)
            .font(Theme.Typography.caption)
            .foregroundStyle(AppTheme.textOnAccent)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(color)
            )
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    ThemePreviewGallery()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ThemePreviewGallery()
        .preferredColorScheme(.dark)
}

#Preview("Side by Side") {
    HStack(spacing: 0) {
        ThemePreviewGallery()
            .preferredColorScheme(.light)
            .frame(maxWidth: .infinity)

        ThemePreviewGallery()
            .preferredColorScheme(.dark)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Onboarding Preview

#Preview("Onboarding - Light") {
    VStack(spacing: 0) {
        // Title section
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("What is your goal?")
                .font(Theme.Typography.largeTitle)
                .foregroundStyle(AppTheme.textPrimary)

            Text("This helps us create your personalized plan.")
                .font(Theme.Typography.subtitle)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.bottom, Theme.Spacing.xxl)

        Spacer()

        // Options
        VStack(spacing: Theme.Spacing.md) {
            OptionCard(title: "Reduce stiffness", subtitle: "Less tension in your body", isSelected: true) {}
            OptionCard(title: "Improve posture", subtitle: "Stand taller, feel better", isSelected: false) {}
            OptionCard(title: "Move more", subtitle: "Break the sedentary cycle", isSelected: false) {}
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)

        Spacer()
        Spacer()

        // Continue button
        PrimaryButton(title: "Continue", isEnabled: true) {}
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, Theme.Spacing.bottomArea)
    }
    .deskFitScreenBackground()
    .preferredColorScheme(.light)
}

#Preview("Onboarding - Dark") {
    VStack(spacing: 0) {
        // Title section
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("What is your goal?")
                .font(Theme.Typography.largeTitle)
                .foregroundStyle(AppTheme.textPrimary)

            Text("This helps us create your personalized plan.")
                .font(Theme.Typography.subtitle)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.bottom, Theme.Spacing.xxl)

        Spacer()

        // Options
        VStack(spacing: Theme.Spacing.md) {
            OptionCard(title: "Reduce stiffness", subtitle: "Less tension in your body", isSelected: true) {}
            OptionCard(title: "Improve posture", subtitle: "Stand taller, feel better", isSelected: false) {}
            OptionCard(title: "Move more", subtitle: "Break the sedentary cycle", isSelected: false) {}
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)

        Spacer()
        Spacer()

        // Continue button
        PrimaryButton(title: "Continue", isEnabled: true) {}
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
            .padding(.bottom, Theme.Spacing.bottomArea)
    }
    .deskFitScreenBackground()
    .preferredColorScheme(.dark)
}
