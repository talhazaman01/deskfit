import SwiftUI
import StoreKit
import Combine

struct PaywallView: View {
    let source: String

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @StateObject private var viewModel = PaywallViewModel()

    /// View-local flag to ensure loadProducts is called only once per view lifetime
    @State private var didLoadProducts = false

    /// Controls display of "How free trial works" modal
    @State private var showTrialInfoModal = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    headerSection
                    benefitsSection
                    plansSection
                    trialInfoButton
                    subscribeButton
                    legalText
                    legalLinks
                    skipButton
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
                .padding(.vertical, Theme.Spacing.lg)
            }
            .deskFitScreenBackground()
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
            .task {
                // Load products once when view appears (guarded by view-local flag)
                guard !didLoadProducts else { return }
                didLoadProducts = true
                await subscriptionManager.loadProducts()
            }
            .onAppear {
                AnalyticsService.shared.track(.paywallViewed(source: source))
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $showTrialInfoModal) {
                FreeTrialInfoModal()
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

    // MARK: - Plans Section

    @ViewBuilder
    private var plansSection: some View {
        switch subscriptionManager.productLoadState {
        case .idle, .loading:
            // Skeleton loading state
            VStack(spacing: Theme.Spacing.md) {
                SkeletonPlanCard(isBestValue: true)
                SkeletonPlanCard(isBestValue: false)
            }

        case .loaded:
            // Successfully loaded - show real plans
            VStack(spacing: Theme.Spacing.md) {
                // Annual plan - with 7-day trial
                if let annual = subscriptionManager.annualProduct {
                    PlanCard(
                        title: "Annual",
                        label: "Best value",
                        priceText: annual.displayPrice,
                        periodText: periodText(for: annual),
                        monthlyEquivalentText: monthlyEquivalentText(for: annual),
                        strikethroughText: strikethroughMonthlyText(),
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
                        label: "Flexible",
                        priceText: monthly.displayPrice,
                        periodText: periodText(for: monthly),
                        monthlyEquivalentText: nil,
                        strikethroughText: nil,
                        savingsText: nil,
                        trialText: nil,
                        isSelected: viewModel.selectedPlan == .monthly,
                        isBestValue: false
                    ) {
                        viewModel.selectedPlan = .monthly
                        AnalyticsService.shared.track(.planSelected(plan: "monthly"))
                    }
                }

                // DEBUG: Reload button for testing
                #if DEBUG
                debugReloadButton
                #endif
            }

        case .timeout, .failed:
            // Error/Timeout state - show friendly fallback
            StoreUnavailableView(
                loadState: subscriptionManager.productLoadState,
                isSimulator: subscriptionManager.isRunningOnSimulator,
                errorMessage: subscriptionManager.userFacingErrorMessage,
                onTryAgain: {
                    Task { await subscriptionManager.forceReloadProducts() }
                },
                onContinueFree: {
                    AnalyticsService.shared.track(.paywallDismissed(source: source, selectedPlan: nil))
                    dismiss()
                },
                onRestorePurchases: {
                    Task {
                        await subscriptionManager.restorePurchases()
                        if subscriptionManager.isProUser {
                            dismiss()
                        }
                    }
                }
            )
        }
    }

    // MARK: - Subscribe Button

    @ViewBuilder
    private var subscribeButton: some View {
        // Only show when products are loaded
        if subscriptionManager.productLoadState == .loaded {
            PrimaryButton(
                title: subscribeButtonTitle,
                isEnabled: !subscriptionManager.products.isEmpty,
                isLoading: viewModel.isPurchasing
            ) {
                handlePurchase()
            }
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
        Group {
            if subscriptionManager.productLoadState == .loaded {
                Text("Cancel anytime. Subscription auto-renews unless cancelled at least 24 hours before the end of the current period.")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Trial Info Button

    @ViewBuilder
    private var trialInfoButton: some View {
        if subscriptionManager.productLoadState == .loaded,
           viewModel.selectedPlan == .annual,
           let annual = subscriptionManager.annualProduct,
           annual.subscription?.introductoryOffer != nil {
            Button {
                showTrialInfoModal = true
            } label: {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "questionmark.circle")
                    Text("How the free trial works")
                }
                .font(Theme.Typography.caption)
                .foregroundStyle(.appTeal)
            }
        }
    }

    // MARK: - Legal Links (Restore, Terms, Privacy)

    @ViewBuilder
    private var legalLinks: some View {
        if subscriptionManager.productLoadState == .loaded {
            HStack(spacing: Theme.Spacing.lg) {
                Button("Restore") {
                    Task {
                        await subscriptionManager.restorePurchases()
                        if subscriptionManager.isProUser {
                            dismiss()
                        }
                    }
                }

                Text("•")
                    .foregroundStyle(.textTertiary)

                Link("Terms", destination: URL(string: "https://deskfit.app/terms")!)

                Text("•")
                    .foregroundStyle(.textTertiary)

                Link("Privacy", destination: URL(string: "https://deskfit.app/privacy")!)
            }
            .font(Theme.Typography.caption)
            .foregroundStyle(.textSecondary)
        }
    }

    // MARK: - Skip

    private var skipButton: some View {
        Group {
            if subscriptionManager.productLoadState == .loaded {
                Button("Continue with limited version") {
                    AnalyticsService.shared.track(.paywallDismissed(source: source, selectedPlan: nil))
                    dismiss()
                }
                .font(Theme.Typography.subtitle)
                .foregroundStyle(.textSecondary)
                .padding(.bottom, Theme.Spacing.xxl)
            }
        }
    }

    // MARK: - Debug

    #if DEBUG
    private var debugReloadButton: some View {
        Button {
            Task { await subscriptionManager.forceReloadProducts() }
        } label: {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "arrow.clockwise")
                Text("Reload Products")
            }
            .font(Theme.Typography.caption)
            .foregroundStyle(.textTertiary)
        }
        .disabled(!subscriptionManager.canAttemptLoadProducts)
        .opacity(subscriptionManager.canAttemptLoadProducts ? 1.0 : 0.5)
    }
    #endif

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

    /// Calculates savings percentage for annual vs monthly.
    /// Only returns a value if savings is between 15% and 70% (to avoid far-fetched numbers).
    private func calculateSavings() -> String? {
        guard let monthly = subscriptionManager.monthlyProduct,
              let annual = subscriptionManager.annualProduct else { return nil }

        let yearlyIfMonthly = monthly.price * Decimal(12)
        guard yearlyIfMonthly > 0 else { return nil }

        let savingsPercent = 1.0 - (NSDecimalNumber(decimal: annual.price).doubleValue /
                                     NSDecimalNumber(decimal: yearlyIfMonthly).doubleValue)
        let roundedPercent = Int((savingsPercent * 100).rounded())

        // Only show if between 15% and 70% to avoid looking scammy
        guard roundedPercent >= 15, roundedPercent <= 70 else { return nil }
        return "Save \(roundedPercent)%"
    }

    /// Calculates the monthly equivalent price from annual subscription (annual_price / 12).
    /// Returns a formatted string like "£2.49/mo" using the product's locale.
    private func monthlyEquivalentText(for product: Product) -> String? {
        guard product.subscription?.subscriptionPeriod.unit == .year else { return nil }

        let monthlyEquivalent = product.price / Decimal(12)
        let formatted = formatPrice(monthlyEquivalent, using: product)
        return "\(formatted)/mo"
    }

    /// Shows the monthly price as strikethrough reference when comparing annual savings.
    /// Returns the monthly price formatted like "£4.99/mo" for visual anchoring.
    private func strikethroughMonthlyText() -> String? {
        guard let monthly = subscriptionManager.monthlyProduct,
              subscriptionManager.annualProduct != nil else { return nil }

        // Only show strikethrough if savings is in valid range
        guard calculateSavings() != nil else { return nil }

        return "\(monthly.displayPrice)/mo"
    }

    /// Formats a Decimal price using the product's currency format.
    /// Handles locale-specific formatting robustly.
    private func formatPrice(_ price: Decimal, using product: Product) -> String {
        var formatStyle = product.priceFormatStyle
        formatStyle.locale = product.priceFormatStyle.locale
        return formatStyle.format(price)
    }

    private func handlePurchase() {
        viewModel.isPurchasing = true

        Task {
            defer { viewModel.isPurchasing = false }

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
    let label: String
    let priceText: String
    let periodText: String
    let monthlyEquivalentText: String?
    let strikethroughText: String?
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
                        // Title row with label badge
                        HStack(spacing: Theme.Spacing.sm) {
                            Text(title)
                                .font(Theme.Typography.headline)
                                .foregroundStyle(.textPrimary)

                            Text(label.uppercased())
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, Theme.Spacing.sm)
                                .padding(.vertical, 2)
                                .background(isBestValue ? Color.appCoral : Color.textTertiary.opacity(0.3))
                                .foregroundStyle(isBestValue ? .textOnDark : .textSecondary)
                                .clipShape(Capsule())
                        }

                        // Price row
                        HStack(spacing: Theme.Spacing.xs) {
                            Text(priceText)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.textPrimary)
                            Text(periodText)
                                .font(Theme.Typography.caption)
                                .foregroundStyle(.textSecondary)
                        }

                        // Monthly equivalent with strikethrough comparison (for annual plan)
                        if let equivalent = monthlyEquivalentText {
                            HStack(spacing: Theme.Spacing.xs) {
                                if let strikethrough = strikethroughText {
                                    Text(strikethrough)
                                        .font(Theme.Typography.caption)
                                        .foregroundStyle(.textTertiary)
                                        .strikethrough(true, color: .textTertiary)
                                }
                                Text(equivalent)
                                    .font(Theme.Typography.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.textSecondary)
                            }
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
                        if let savings = savingsText {
                            Text(savings)
                                .font(Theme.Typography.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.success)
                        }

                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isSelected ? .appCoral : .textSecondary)
                            .font(.title2)
                    }
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
                            .strokeBorder(isSelected ? Color.appCoral : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct SkeletonPlanCard: View {
    let isBestValue: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack(spacing: Theme.Spacing.sm) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.progressBackground)
                            .frame(width: 60, height: 20)

                        if isBestValue {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.progressBackground)
                                .frame(width: 80, height: 16)
                        }
                    }

                    HStack(spacing: Theme.Spacing.xs) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.progressBackground)
                            .frame(width: 70, height: 24)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.progressBackground)
                            .frame(width: 50, height: 14)
                    }
                }

                Spacer()

                Circle()
                    .fill(Color.progressBackground)
                    .frame(width: 28, height: 28)
            }

            if isBestValue {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.progressBackground)
                    .frame(width: 100, height: 14)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Color.cardBackground)
        )
        .shimmer()
    }
}

struct StoreUnavailableView: View {
    let loadState: SubscriptionManager.ProductLoadState
    let isSimulator: Bool
    let errorMessage: String?
    let onTryAgain: () -> Void
    let onContinueFree: () -> Void
    let onRestorePurchases: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: isSimulator ? "hammer.fill" : "exclamationmark.icloud")
                .font(.system(size: 40))
                .foregroundStyle(isSimulator ? .warning : .textSecondary)

            Text(isSimulator ? "Simulator Setup Required" : "Store unavailable right now")
                .font(Theme.Typography.headline)
                .foregroundStyle(.textPrimary)

            Text(errorMessage ?? fallbackMessageText)
                .font(Theme.Typography.caption)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)

            // Debug hint for simulator with setup steps
            #if DEBUG
            if case .failed(let reason) = loadState,
               reason == .simulatorMissingConfig {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Setup Steps:")
                        .font(Theme.Typography.caption)
                        .fontWeight(.semibold)
                    Text("1. Product > Scheme > Edit Scheme")
                    Text("2. Run > Options tab")
                    Text("3. StoreKit Configuration: DeskFit.storekit")
                }
                .font(Theme.Typography.caption)
                .foregroundStyle(.warning)
                .padding(Theme.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.warning.opacity(0.1))
                .cornerRadius(Theme.Radius.small)
            }
            #endif

            VStack(spacing: Theme.Spacing.md) {
                Button(action: onTryAgain) {
                    Text("Try again")
                        .font(Theme.Typography.button)
                        .foregroundStyle(.textOnAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(Color.appCoral)
                        .cornerRadius(Theme.Radius.medium)
                }

                Button(action: onContinueFree) {
                    Text("Continue with Free")
                        .font(Theme.Typography.button)
                        .foregroundStyle(.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(Color.cardBackground)
                        .cornerRadius(Theme.Radius.medium)
                }

                Button(action: onRestorePurchases) {
                    Text("Restore Purchases")
                        .font(Theme.Typography.subtitle)
                        .foregroundStyle(.textSecondary)
                }
            }
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Color.cardBackground)
        )
    }

    /// Fallback message if errorMessage is nil
    private var fallbackMessageText: String {
        switch loadState {
        case .timeout:
            return "The connection timed out. Please check your internet and try again."
        case .failed(let reason):
            switch reason {
            case .networkError:
                return "Unable to connect. Please check your internet connection."
            case .simulatorMissingConfig:
                return "Store not configured for Simulator. Attach DeskFit.storekit to your Run Scheme."
            default:
                return "Something went wrong. Please try again later."
            }
        default:
            return "Please try again."
        }
    }
}

// MARK: - Free Trial Info Modal

struct FreeTrialInfoModal: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xxl) {
                    // Header
                    VStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.appTeal)

                        Text("How your free trial works")
                            .font(Theme.Typography.largeTitle)
                            .foregroundStyle(.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Theme.Spacing.xl)

                    // Timeline
                    VStack(spacing: 0) {
                        TrialTimelineRow(
                            day: "Today",
                            icon: "checkmark.circle.fill",
                            iconColor: .appTeal,
                            title: "Unlock full access",
                            description: "Start your 7-day free trial and explore all premium features.",
                            isFirst: true,
                            isLast: false
                        )

                        TrialTimelineRow(
                            day: "Day 5",
                            icon: "bell.fill",
                            iconColor: .warning,
                            title: "Reminder notification",
                            description: "We'll send you a reminder before your trial ends. No surprises.",
                            isFirst: false,
                            isLast: false
                        )

                        TrialTimelineRow(
                            day: "Day 7",
                            icon: "star.fill",
                            iconColor: .success,
                            title: "Trial ends",
                            description: "Your subscription begins. Cancel anytime before if you change your mind.",
                            isFirst: false,
                            isLast: true
                        )
                    }
                    .padding(.horizontal, Theme.Spacing.md)

                    // Note
                    Text("You won't be charged during the trial period. Cancel anytime in Settings > Subscriptions.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.lg)

                    Spacer(minLength: Theme.Spacing.xxl)
                }
                .padding(.horizontal, Theme.Spacing.screenHorizontal)
            }
            .deskFitScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.textSecondary)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

struct TrialTimelineRow: View {
    let day: String
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            // Timeline line and dot
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.progressBackground)
                        .frame(width: 2, height: Theme.Spacing.md)
                }

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(iconColor)
                    .frame(width: 32, height: 32)

                if !isLast {
                    Rectangle()
                        .fill(Color.progressBackground)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 32)

            // Content
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(day)
                    .font(Theme.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.appTeal)

                Text(title)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.textPrimary)

                Text(description)
                    .font(Theme.Typography.body)
                    .foregroundStyle(.textSecondary)
            }
            .padding(.bottom, Theme.Spacing.lg)

            Spacer()
        }
    }
}

// MARK: - Shimmer Effect

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.6)
                    .offset(x: phase * geometry.size.width * 1.6 - geometry.size.width * 0.3)
                }
            )
            .clipped()
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}
