//
//  PaywallViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 20/2/25.
//

import UIKit
import PanModal
import StoreKit
import SafariServices
import ApphudSDK

enum screenPaywall: String{
    case onboarding = "Onboarding Paywall"
    case getPro = "Get Pro Paywall"
    case limitPaywall = "Limit Paywall"
}
struct PlanSubscriptionModel {
    var type: PlanType
    var skProduct: SKProduct
    var apphudProduct: ApphudProduct
}
enum PlanType: String, Equatable {
    case weekly
    case monthly
    case yearly
    
    init?(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .weekly
        case 1:
            self = .monthly
        default:
            self = .yearly
        }
    }
    
    var index: Int {
        switch self {
        case .weekly:
            return 0
        case .monthly:
            return 1
        case .yearly:
            return 2
        }
    }
    
    var unit: SKProduct.PeriodUnit? {
        switch self {
        case .weekly:
            return .week
        case .monthly:
            return .month
        case .yearly:
            return .year
        }
    }
    
    var productId: String {
        switch self {
        case .weekly:
            return INAPP_PURCHASE.weekly
        case .monthly:
            return INAPP_PURCHASE.montly
        case .yearly:
            return INAPP_PURCHASE.yearly
        }
    }
}
class PaywallViewController: BaseViewController {

    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var arrViewPackages: [UIView]!
    @IBOutlet var arrSelectPaywalls: [UIImageView]!
    private var priceSelected: PlanType = .monthly
    @IBOutlet weak var lblPriceWeek: UILabel!
    @IBOutlet weak var lblPriceMonthlt: UILabel!
    @IBOutlet weak var lblPriceYear: UILabel!
    @IBOutlet weak var lblValueBest: UILabel!
    var typePaywall: screenPaywall = .getPro
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchProducts()
        // Do any additional setup after loading the view.
    }
    

    
    private func fetchProducts(){
        InApPurchaseManager.shared.fetchPayWalls { products in
            print("products--->",products.count)
            for product in products {
                if product.productId == INAPP_PURCHASE.weekly{
                    let price = self.formatPriceProduct(product: product)
                    self.lblPriceWeek.text = price
                }
                else if product.productId == INAPP_PURCHASE.montly{
                    let price = self.formatPriceProduct(product: product)
                    self.lblPriceMonthlt.text = price
                }
                else if product.productId == INAPP_PURCHASE.yearly{
                    let price = self.formatPriceProduct(product: product)
                    self.lblPriceYear.text = price
                }
            }
        }
    }
    
    private func formatPriceProduct(product: ApphudProduct) -> String{
         if let skProduct = product.skProduct {
            
            let price = skProduct.price
            let locale = skProduct.priceLocale
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = locale
             formatter.minimumIntegerDigits = 0
             let priceValue = price.doubleValue
                 if priceValue.truncatingRemainder(dividingBy: 1) == 0 {
                     formatter.maximumFractionDigits = 0
                 } else {
                     formatter.maximumFractionDigits = 2
                 }
            if let formattedPrice = formatter.string(from: price) {
                print("Formatted Price: \(formattedPrice)")
                return formattedPrice
            }
        }
        return ""
    }
    
    @IBAction func doClose(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func doPrivacy(_ sender: Any) {
        if let url = URL.init(string: ConfigSettings.PRIVACY){
            let vc = WebViewController.init()
            vc.url = url
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func doTerm(_ sender: Any) {
        if let url = URL.init(string: ConfigSettings.TERMS){
            let vc = WebViewController.init()
            vc.url = url
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func doPay(_ sender: Any) {
        guard let btn = sender as? UIButton else{
            return
        }
        switch btn.tag {
        case 0:
            priceSelected = .weekly
        case 1:
            priceSelected = .monthly
        case 2:
            priceSelected = .yearly
        default:
            priceSelected = .weekly
        }
        updatePaywall()
    }
    @IBAction func doContinue(_ sender: Any) {
        guard let product = InApPurchaseManager.shared.products?.first(where: {$0.productId == priceSelected.productId }) else { return }
        self.performPurchase(product: product)
    }
    
    private func performPurchase(product: ApphudProduct) {
        self.showBusy()
        InApPurchaseManager.shared.makePurchase(product: product) {[weak self] result in
            self?.hideBusy()
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Inapp success--->",result)
                    if let current = InApPurchaseManager.shared.currentPlanType{
                        AnalyticsManager.shared.trackEvent(.Subscription_Started, properties: [AnalyticsProperty.planType : self.priceSelected.rawValue, AnalyticsProperty.priceUSD: current.skProduct.price , AnalyticsProperty.currency: current.skProduct.priceLocale.currency?.identifier,AnalyticsProperty.screen: self.typePaywall.rawValue])
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(KEY_NOTIFICATION_NAME.PAYWALL_SUCCESS), object: nil)
                    TempStorage.shared.isPremium = true
                    self.dismiss(animated: true)
                   break
                case .failure(let error):
                    print("error--->",error)
                    if error.errorCode == .paymentCancelled {
                        self.showMessageComback(MSG_ERROR.MSG_PURCHASE_CANCEL, complete: { success in
                            
                        })
                    } else {
                        AnalyticsManager.shared.trackEvent(.Error_Occurred, properties: [AnalyticsProperty.errorType: "Appstore", AnalyticsProperty.errorMessage: error.localizedDescription, AnalyticsProperty.screen: "Paywall"])
                        self.showMessageComback(MSG_ERROR.MSG_PURCHAE_ERROR, complete: { success in
                            
                        })
                    }
                }
            }
        }
    }
    
}


extension PaywallViewController{
    private func setupUI(){
        btnContinue.layer.cornerRadius = btnContinue.frame.size.height/2
        btnContinue.layer.masksToBounds = true
        lblValueBest.layer.cornerRadius = 10
        lblValueBest.layer.masksToBounds = true
        updatePaywall()
    }
    private func updatePaywall(){
        for i in 0...arrViewPackages.count - 1{
            if i == priceSelected.index{
                arrViewPackages[i].layer.cornerRadius = 20
                arrViewPackages[i].layer.borderColor =  UIColor.clear.withAlphaComponent(0.14).cgColor
                arrViewPackages[i].borderWidth = 0.0
                arrSelectPaywalls[i].isHidden = false
            }
            else{
                arrViewPackages[i].layer.cornerRadius = 20
                arrViewPackages[i].layer.borderColor =  UIColor.black.withAlphaComponent(0.14).cgColor
                arrViewPackages[i].borderWidth = 1.0
                arrSelectPaywalls[i].isHidden = true
            }
        }
    }
}
