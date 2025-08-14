//
//  AppDelegate.swift
//  Speak-AI
//
//  Created by QTS Coder on 6/2/25.
//

import UIKit
import IQKeyboardManagerSwift
import ApphudSDK
import Mixpanel
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var isOpenRecording: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isOpenRecording")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isOpenRecording")
        }
    }
    var window: UIWindow?
    var detailHomeViewController: DetailRecordingViewController?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.isEnabled = true
        AppSetings.shared.isValidLanguageDefault()
        AppOpenTracker.shared.saveFirstAppOpenDateIfNeeded()
        AnalyticsManager.shared.initialize()
        if AppSetings.shared.isOnboading{
            initHome()
        }
        if !UserDefaults.standard.bool(forKey: KeyDefaults.AllFoders){
            saveCoreDataFoderAll()
        }
        AnalyticsManager.shared.trackEvent(.App_Launched, properties: [AnalyticsProperty.appVersion: Bundle.mainAppVersion ?? "1.0", AnalyticsProperty.osVersion: UIDevice.current.systemVersion, AnalyticsProperty.deviceModel: UIDevice().modelName])
        Apphud.start(apiKey: InApPurchaseManager.Constant.API_KEY.rawValue)
        Apphud.setDelegate(self)
        return true
    }
    func initHome(){
        let homeVC = HomeViewController.instantiate()
        let nav = UINavigationController.init(rootViewController: homeVC)
        nav.isNavigationBarHidden = true
      
        if let window = self.window {
            let options: UIView.AnimationOptions = .transitionCrossDissolve
            UIView.transition(with: window, duration: 0.5, options: options, animations: {
                window.rootViewController = nav
            }, completion: nil)
            window.makeKeyAndVisible()
        }
    }
    
    private func saveCoreDataFoderAll(){
        let folderModel = FolderObj(id: UUID().uuidString, name: "All", order: 1)
        if let folderID = CoreDataManager.shared.saveFolder(folderObj: folderModel) {
            print("Folder saved with ID: \(folderID)")
        } else {
            print("Failed to save folder")
        }
        UserDefaults.standard.set(true, forKey: KeyDefaults.AllFoders)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "myappscheme" && url.host == "openapp" {
            // Xử lý mở app tại đây
            print("Widget clicked, opening app...")
            
            AppDelegate.shared.isOpenRecording = true
            self.initHome()
            return true
        }
        return false
    }
}

extension AppDelegate: ApphudDelegate {
    func userDidLoad(rawPaywalls: [ApphudPaywall]) {
        let identifier = rawPaywalls.map({$0.identifier})
        print(#function, identifier)
        InApPurchaseManager.shared.fetchPayWalls { products in
            for product in products {
                print("products---->",product.productId)
            }
        }
    }
    
    func paywallsDidFullyLoad(paywalls: [ApphudPaywall]) {
        print(#function, paywalls)
    }
}
