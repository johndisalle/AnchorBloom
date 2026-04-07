import Foundation
import Combine
import StoreKit
import UIKit

// MARK: - Subscription Manager
/// Handles StoreKit subscriptions for premium features
@MainActor
final class SubscriptionManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    static let monthlyProductID = "com.anchorbloom.premium.monthly.v2"
    static let yearlyProductID = "com.anchorbloom.premium.yearly.v2"

    private var updateListenerTask: Task<Void, Error>?

    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }

    var monthlyProduct: Product? {
        products.first { $0.id == Self.monthlyProductID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == Self.yearlyProductID }
    }

    init() {
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: [
                Self.monthlyProductID,
                Self.yearlyProductID
            ])
        } catch {
            errorMessage = "Failed to load subscription options."
        }
    }

    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            purchasedProductIDs.insert(transaction.productID)
            await transaction.finish()
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }

    // MARK: - Redeem Offer Code
    /// Presents the system offer code redemption sheet (iOS 16+)
    func redeemOfferCode() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        do {
            try await AppStore.presentOfferCodeRedeemSheet(in: windowScene)
            // After redemption, refresh entitlements to pick up the new subscription
            await restorePurchases()
        } catch {
            errorMessage = "Could not open the offer code redemption. Please try again."
        }
    }

    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await MainActor.run { [productID = transaction.productID] in
                        _ = self.purchasedProductIDs.insert(productID)
                    }
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let item):
            return item
        }
    }
}

// MARK: - Subscription Errors
enum SubscriptionError: LocalizedError {
    case verificationFailed
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .verificationFailed: return "Purchase verification failed."
        case .purchaseFailed: return "Purchase could not be completed."
        }
    }
}
