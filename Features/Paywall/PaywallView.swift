import SwiftUI
import StoreKit

struct PaywallView: View {
    let source: String

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @StateObject private var viewModel = PaywallViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    headerSection
                    benefitsSection
                    plansSection
                    subscribeButton
                    legalText
                    restoreButton
                    skipButton
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.vertical, Theme.Spacing.lg)
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        AnalyticsService.shared.track(.paywallDismissed(source: source, selectedPlan: nil))
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.textSecondary)
                    }
                }
            }
            .onAppear {
                AnalyticsService.shared.track(.paywallViewed(source: source))
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundStyle(.appTeal)

            Text("Unlock Your Full Reset")
                .font(Theme.Typography.largeTitle)
                .foregroundStyle(.textPrimary)

            Text("Get the most out of your breaks")
                .font(Theme.Typography.subtitle)
                .foregroundStyle(.textSecondary)
        }
        .padding(.top, Theme.Spacing.xxl)
    }

    // MARK: - Benefits

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            BenefitRow(icon: "infinity", text: "Unlimited daily breaks")
            BenefitRow(icon: "calendar", text: "Full personalized daily plans")
            BenefitRow(icon: "person.fill", text: "Tailored to your focus areas")
            BenefitRow(icon: "bell.fill", text: "Smart reminder scheduling")
            BenefitRow(icon: "chart.line.uptrend.xyaxis", text: "Detailed progress tracking")
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.cardBackground)
        )
    }

    // MARK: - Plans (Prices from StoreKit)

    private var plansSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Annual plan - with 7-day trial
            if let annual = subscriptionManager.annualProduct {
                PlanCard(
                    title: "Annual",
                    priceText: annual.displayPrice,
                    periodText: periodText(for: annual),
                    savingsText: calculateSavings(),
                    trialText: trialText(for: annual),
                    isSelected: viewModel.selectedPlan == .annual,
                    isBestValue: true
                ) {
                    viewModel.selectedPlan = .annual
                    AnalyticsService.shared.track(.planSelected(plan: "annual"))
                }
            }

            // Monthly plan
            if let monthly = subscriptionManager.monthlyProduct {
                PlanCard(
                    title: "Monthly",
                    priceText: monthly.displayPrice,
                    periodText: periodText(for: monthly),
                    savingsText: nil,
                    trialText: nil,
                    isSelected: viewModel.selectedPlan == .monthly,
                    isBestValue: false
                ) {
                    viewModel.selectedPlan = .monthly
                    AnalyticsService.shared.track(.planSelected(plan: "monthly"))
                }
            }

            // Loading state
            if subscriptionManager.products.isEmpty && subscriptionManager.isLoading {
                ProgressView("Loading plans...")
                    .padding(Theme.Spacing.lg)
            }

            // Error state
            if subscriptionManager.products.isEmpty && !subscriptionManager.isLoading {
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Unable to load subscription options")
                        .font(Theme.Typography.body)
                        .foregroundStyle(.textSecondary)
                    Button("Try Again") {
                        Task { await subscriptionManager.loadProducts() }
                    }
                    .foregroundStyle(.appTeal)
                }
                .padding(Theme.Spacing.lg)
            }
        }
    }

    // MARK: - Subscribe Button

    private var subscribeButton: some View {
        PrimaryButton(
            title: subscribeButtonTitle,
            isEnabled: !subscriptionManager.products.isEmpty,
            isLoading: subscriptionManager.isLoading
        ) {
            handlePurchase()
        }
    }

    private var subscribeButtonTitle: String {
        if viewModel.selectedPlan == .annual {
            if let annual = subscriptionManager.annualProduct,
               annual.subscription?.introductoryOffer != nil {
                return "Start Free Trial"
            }
        }
        return "Continue"
    }

    // MARK: - Legal

    private var legalText: some View {
        Text("Cancel anytime. Subscription auto-renews unless cancelled at least 24 hours before the end of the current period.")
            .font(Theme.Typography.caption)
            .foregroundStyle(.textTertiary)
            .multilineTextAlignment(.center)
    }

    // MARK: - Restore

    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task {
                await subscriptionManager.restorePurchases()
                if subscriptionManager.isProUser {
                    dismiss()
                }
            }
        }
        .font(Theme.Typography.subtitle)
        .foregroundStyle(.textSecondary)
    }

    // MARK: - Skip

    private var skipButton: some View {
        Button("Continue with limited version") {
            AnalyticsService.shared.track(.paywallDismissed(source: source, selectedPlan: nil))
            dismiss()
        }
        .font(Theme.Typography.subtitle)
        .foregroundStyle(.textSecondary)
        .padding(.bottom, Theme.Spacing.xxl)
    }

    // MARK: - Helpers

    private func periodText(for product: Product) -> String {
        guard let subscription = product.subscription else { return "" }

        switch subscription.subscriptionPeriod.unit {
        case .month:
            return "per month"
        case .year:
            return "per year"
        case .week:
            return "per week"
        case .day:
            return "per day"
        @unknown default:
            return ""
        }
    }

    private func trialText(for product: Product) -> String? {
        guard let offer = product.subscription?.introductoryOffer else { return nil }

        switch offer.period.unit {
        case .day:
            return "\(offer.period.value)-day free trial"
        case .week:
            return "\(offer.period.value)-week free trial"
        case .month:
            return "\(offer.period.value)-month free trial"
        case .year:
            return "\(offer.period.value)-year free trial"
        @unknown default:
            return nil
        }
    }

    private func calculateSavings() -> String? {
        guard let monthly = subscriptionManager.monthlyProduct,
              let annual = subscriptionManager.annualProduct else { return nil }

        let yearlyIfMonthly = monthly.price * 12
        let savings = yearlyIfMonthly - annual.price
        let savingsPercent = Int((savings / yearlyIfMonthly) * 100)

        guard savingsPercent > 0 else { return nil }
        return "Save \(savingsPercent)%"
    }

    private func handlePurchase() {
        Task {
            let product = viewModel.selectedPlan == .annual
                ? subscriptionManager.annualProduct
                : subscriptionManager.monthlyProduct

            guard let product = product else { return }

            do {
                let success = try await subscriptionManager.purchase(product)
                if success {
                    dismiss()
                }
            } catch {
                viewModel.errorMessage = error.localizedDescription
                viewModel.showError = true
                AnalyticsService.shared.track(.subscribeFailed(
                    plan: viewModel.selectedPlan.rawValue,
                    errorCode: error.localizedDescription
                ))
            }
        }
    }
}

// MARK: - Subviews

struct BenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(.appTeal)
                .frame(width: 24)

            Text(text)
                .font(Theme.Typography.body)
                .foregroundStyle(.textPrimary)

            Spacer()
        }
    }
}

struct PlanCard: View {
    let title: String
    let priceText: String
    let periodText: String
    let savingsText: String?
    let trialText: String?
    let isSelected: Bool
    let isBestValue: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        HStack(spacing: Theme.Spacing.sm) {
                            Text(title)
                                .font(Theme.Typography.headline)
                                .foregroundStyle(.textPrimary)

                            if isBestValue {
                                Text("BEST VALUE")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, Theme.Spacing.sm)
                                    .padding(.vertical, 2)
                                    .background(Color.appTeal)
                                    .foregroundStyle(.textOnDark)
                                    .clipShape(Capsule())
                            }
                        }

                        HStack(spacing: Theme.Spacing.xs) {
                            Text(priceText)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.textPrimary)
                            Text(periodText)
                                .font(Theme.Typography.caption)
                                .foregroundStyle(.textSecondary)
                        }
                    }

                    Spacer()

                    if let savings = savingsText {
                        Text(savings)
                            .font(Theme.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.success)
                    }

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? .appTeal : .textSecondary)
                        .font(.title2)
                }

                if let trial = trialText {
                    Text(trial)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.appTeal)
                }
            }
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.medium)
                            .strokeBorder(isSelected ? Color.appTeal : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
