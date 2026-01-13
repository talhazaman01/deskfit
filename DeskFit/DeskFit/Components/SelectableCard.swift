import SwiftUI

struct SelectableCard<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button(action: action) {
            content()
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    isSelected ? Color.brandPrimary : Color.clear,
                                    lineWidth: 2
                                )
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

struct SelectableRow: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        SelectableCard(isSelected: isSelected, action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(isSelected ? .brandPrimary : .secondary)
                        .frame(width: 32)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .brandPrimary : .secondary)
                    .font(.title2)
            }
        }
    }
}

struct MultiSelectableRow: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(isSelected ? .brandPrimary : .secondary)
                        .frame(width: 28)
                }

                Text(title)
                    .font(.body)
                    .foregroundStyle(.textPrimary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isSelected ? .brandPrimary : .secondary)
                    .font(.title3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? Color.brandPrimary : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        SelectableRow(
            title: "Move More",
            subtitle: "Get more movement into your day",
            icon: "figure.run",
            isSelected: true
        ) {}

        SelectableRow(
            title: "Build a Habit",
            subtitle: "Create a consistent routine",
            icon: "calendar",
            isSelected: false
        ) {}

        MultiSelectableRow(
            title: "Neck",
            icon: "figure.stand",
            isSelected: true
        ) {}
    }
    .padding()
}
