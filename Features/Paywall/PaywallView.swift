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
                VStack(spacing: 24) {
                    headerSection
                    benefitsSection
                    plansSection
                    subscribeButton
                    legalText
                    restoreButton
                    skipButton
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        AnalyticsService.shared.track(.paywallDismissed(source: source, selectedPlan: nil))
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.secondary)
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
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundStyle(.brandPrimary)

            Text("Unlock Your Full Reset")
                .font(.title)
                .fontWeight(.bold)

            Text("Get the most out of your breaks")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 32)
    }

    // MARK: - Benefits

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            BenefitRow(icon: "infinity", text: "Unlimited daily breaks")
            BenefitRow(icon: "calendar", text: "Full personalized daily plans")
            BenefitRow(icon: "person.fill", text: "Tailored to your focus areas")
            BenefitRow(icon: "bell.fill", text: "Smart reminder scheduling")
            BenefitRow(icon: "chart.line.uptrend.xyaxis", text: "Detailed progress tracking")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondaryBackground)
        )
    }

    // MARK: - Plans (Prices from StoreKit)

    private var plansSection: some View {
        VStack(spacing: 12) {
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
                    .padding()
            }

            // Error state
            if subscriptionManager.products.isEmpty && !subscriptionManager.isLoading {
                VStack(spacing: 8) {
                    Text("Unable to load subscription options")
                        .foregroundStyle(.secondary)
                    Button("Try Again") {
                        Task { await subscriptionManager.loadProducts() }
                    }
                }
                .padding()
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
            .font(.caption)
            .foregroundStyle(.secondary)
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
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    // MARK: - Skip

    private var skipButton: some View {
        Button("Continue with limited version") {
            AnalyticsService.shared.track(.paywallDismissed(source: source, selectedPlan: nil))
            dismiss()
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .padding(.bottom, 32)
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
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.brandPrimary)
                .frame(width: 24)

            Text(text)
                .font(.body)

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
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(title)
                                .font(.headline)

                            if isBestValue {
                                Text("BEST VALUE")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.brandPrimary)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                        }

                        HStack(spacing: 4) {
                            Text(priceText)
                                .font(.title3)
                                .fontWeight(.bold)
                            Text(periodText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if let savings = savingsText {
                        Text(savings)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                    }

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? .brandPrimary : .secondary)
                        .font(.title2)
                }

                if let trial = trialText {
                    Text(trial)
                        .font(.caption)
                        .foregroundStyle(.brandPrimary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isSelected ? Color.brandPrimary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
