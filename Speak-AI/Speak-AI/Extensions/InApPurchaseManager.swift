//
//  IAPManager.swift

import Foundation
import ApphudSDK
import StoreKit

extension InApPurchaseManager {
    enum Constant: String {
        case API_KEY                 = "app_FHpwcqykQi2UuZ9qmzg39UgtHeVS4P"
        case APP_STORE_SHARED_SECRET = "7200477e29904e53962cbb53ec17167d"
        case PAYWALL_IDENTIFIER      = "explorer"
    }
}

enum MembershipPayment: String {
    case pro = "Pro"
    case basic = "Basic"
    case previouslyPro = "Previously Pro"
}

enum PurchaseType {
    case subscribe
    case onetime
    case none
}

class InApPurchaseManager: ApphudDelegate {
    static let shared = InApPurchaseManager()
    
    var paywall: ApphudPaywall?
    var products: [ApphudProduct]?
    
    var purchaseType: PurchaseType {
 
        if isPremiumActive {
            if Apphud.nonRenewingPurchases()?.first(where: { $0.isActive() }) != nil {
                return .onetime
            }
            if Apphud.subscription() != nil {
                return .subscribe
            }
        }
        return .none
    }
    
    var isPremiumActive: Bool {
       
        if Apphud.nonRenewingPurchases()?.first(where: { $0.isActive() }) != nil {
            return true
        }
        guard let subscription = Apphud.subscriptions()?.first(where: {$0.isActive()}) else {
            return false
        }
       
        print(subscription.expiresDate)
        return subscription.expiresDate.timeIntervalSince1970 > Date().timeIntervalSince1970
    }
    
    var expiresDate: Date{
        guard let subscription = Apphud.subscriptions()?.first(where: {$0.isActive()}) else {
            return Date()
        }
        print(subscription.expiresDate)
        return subscription.expiresDate
    }
    
    var currentPlanType: PlanSubscriptionModel? {
        guard let products = InApPurchaseManager.shared.products, !products.isEmpty else {
            return nil
        }
        
        guard let sub = Apphud.subscriptions()?.last(where: { $0.isActive()}) else {
            return nil
        }
        return allPlans.first(where: { $0.type.productId == sub.productId})
    }
    
    var allPlans: [PlanSubscriptionModel] {
        var plans = [PlanSubscriptionModel]()
        guard let products = InApPurchaseManager.shared.products, !products.isEmpty else {
             return plans
        }
        
        for product in products {
            guard let skProduct = product.skProduct else {
                continue
            }
            switch product.productId {
            case PlanType.weekly.productId:
                plans.append(PlanSubscriptionModel(type: .weekly, skProduct: skProduct, apphudProduct: product))
            case PlanType.monthly.productId:
                plans.append(PlanSubscriptionModel(type: .monthly, skProduct: skProduct, apphudProduct: product))
            default:
                continue
            }
        }
        return plans.sorted(by: { $0.type.index < $1.type.index})
    }
    
    var otherPlans: [PlanSubscriptionModel] {
        guard allPlans.isNotEmpty else {
            return []
        }
        
        var others = allPlans
        others.removeAll(where: { $0.type == currentPlanType?.type})
        return others
    }
    
    var showSubscriptionActive: Bool {
        guard Apphud.nonRenewingPurchases()?.first(where: { $0.isActive() }) != nil else {
            return false
        }
        guard let subscription = Apphud.subscriptions()?.first(where: { $0.isActive()}) else {
            return false
        }
        
        guard subscription.isAutorenewEnabled else {
            return false
        }

        return subscription.expiresDate.timeIntervalSince1970 > Date().timeIntervalSince1970
    }
    
  
 
    var membershipStatus: MembershipPayment {
       
        guard let subscription = Apphud.subscription() else {
            return .basic
        }
        
        if subscription.expiresDate.timeIntervalSince1970 < Date().timeIntervalSince1970 {
            return .previouslyPro
        }
        return .basic
    }
    
    var remainingSubscriptionTime: TimeInterval {
        guard let subscription = Apphud.subscriptions()?.first(where: {$0.isActive()}) else {
            return 0
        }
        return (subscription.expiresDate.timeIntervalSince1970 - Date().timeIntervalSince1970)
    }
    
    
    
    
    // MARK: - Funtions
    
    func fetchPayWalls(completion: @escaping (_ products: [ApphudProduct]) -> Void) {
        Apphud.paywallsDidLoadCallback { [self] (paywalls) in
            paywall = paywalls.first(where: { $0.identifier == Constant.PAYWALL_IDENTIFIER.rawValue })
            products = paywall?.products
            completion(paywall?.products ?? [])
        }
    }
    
    func makePurchase(product: ApphudProduct, completion: @escaping (Result<Bool, PurchaseError>) -> Void) {
        Apphud.purchase(product) { result in
            if result.success{
                if let subscription = result.subscription, subscription.isActive() {
                    completion(.success(true))
                } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                    completion(.success(true))
                } else {
                    guard let error = result.error else {
                        return completion(.success(false))
                    }
                    completion(.failure(PurchaseError(error: error as? SKError)))
                }
            }
            else{
                guard let error = result.error else {
                    return completion(.success(false))
                }
                completion(.failure(PurchaseError(error: error as? SKError)))
            }
           
        }
    }
    
    func restorePurchase(completion: @escaping (Result<Bool, PurchaseError>) -> Void) {
        Apphud.restorePurchases{ subscriptions, purchases, error in
            if Apphud.hasActiveSubscription() {
                completion(.success(true))
            } else {
                guard let error = error else {
                    return completion(.success(false))
                }
                completion(.failure(PurchaseError(error: error as? SKError)))
            }
        }
    }
}


final class PurchaseError: Error {
    
    var message = "Sorry, your purchase cannot be completed. Please, try again later."
    var title = "Purchase Failed"
    var error: SKError?
    var errorCode: SKError.Code = .unknown
    
    init(error: SKError?) {
        self.error = error
        guard let error = error else { return }
        self.errorCode = error.code
        switch error.code {
        case .unknown:
            self.message = "Sorry, the purchase is unavailable for an unknown reason. Please try again later."
        case .paymentCancelled:
            self.message = "You have canceled your purchase."
            self.title = "Purchase Canceled"
        case .clientInvalid:
            self.message = "The purchase cannot be completed. Please, change your account or device."
        case .paymentInvalid:
            self.message = "Your purchase was declined. Please, check the payment details and make sure there are enough funds in your account."
        case .paymentNotAllowed:
            self.message = "The purchase is not available for the selected payment method. Please, make sure your payment method allows you to make online purchases."
        case .storeProductNotAvailable:
            self.message = "To be honest, I have never met such an error. Actually, you can just write that the purchase was declined."
        case .cloudServicePermissionDenied:
            self.message = "The purchase cannot be completed because your device is not connected to the Internet. Please, try again later with a stable internet connection."
        case .cloudServiceRevoked:
            self.message = "Sorry, an error has occurred."
        case .privacyAcknowledgementRequired:
            self.message = "The purchase cannot be completed because you have not accepted the terms of use of the AppStore. Please, confirm your consent in the settings and then return to the purchase."
        case .unauthorizedRequestData:
            self.message = "An error has occurred. Please, try again later."
        case .invalidOfferIdentifier:
            self.message = "The promotional offer is invalid or expired."
        case .missingOfferParams:
            self.message = "Sorry, an error has occurred when applying the promo offer. Please, try again later."
        case .invalidOfferPrice:
            self.message = "Sorry, your purchase cannot be completed. Please, try again later."
        default:
            self.message = error.localizedDescription
        }
    }
}
extension Collection {
    var isNotEmpty: Bool {
        !isEmpty
    }
}
