//
//  BaseViewController.swift

import UIKit
import MBProgressHUD
import RappleProgressHUD
class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func doSettings(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func showMessageComback(_ message: String , complete:@escaping (_ success: Bool) ->Void){
        let alertVC = UIAlertController.init(title: ConfigSettings.APP_NAME, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "OK".localized(), style: .default) { action in
            complete(true)
        }
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true) {
            
        }
    }
    
    func showBusy()
    {
        var attribute = RappleActivityIndicatorView.attribute(style: .apple, tintColor: UIColor.init(hexString: "FE4F34"), screenBG: .lightGray, progressBG: .black, progressBarBG: .orange, progreeBarFill: .red, thickness: 4)
           attribute[RappleIndicatorStyleKey] = RappleStyleCircle
        RappleActivityIndicatorView.startAnimatingWithLabel("", attributes: attribute)
    }
   
    func hideBusy()
    {
        RappleActivityIndicatorView.stopAnimation()
    }
    
    func impactHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func showOpenSettings(_ message: String , complete:@escaping (_ success: Bool) ->Void){
        let alertVC = UIAlertController.init(title: ConfigSettings.APP_NAME, message: message, preferredStyle: .alert)
        let settingAction = UIAlertAction.init(title: "Settings".localized(), style: .default) { action in
            complete(true)
        }
        alertVC.addAction(settingAction)
        
        let cancelAction = UIAlertAction.init(title: "Cancel".localized(), style: .cancel) { action in
            
        }
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true) {
            
        }
    }
    
}
