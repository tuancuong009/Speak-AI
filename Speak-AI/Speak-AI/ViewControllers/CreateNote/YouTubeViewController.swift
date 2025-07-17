//
//  YouTubeViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 10/2/25.
//

import UIKit
import PanModal
extension YouTubeViewController: PanModalPresentable {
    var allowsDragToDismiss: Bool {
        return false
    }

    // 🔹 Disable tap outside to dismiss
    var allowsTapToDismiss: Bool {
        return false
    }

    // 🔹 Disable any animation when dismissing
    var shouldAnimateDismiss: Bool {
        return false
    }
   
     var allowsExtendedPanScrolling: Bool{
         return false
     }
     
     func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
         return false
     }
     
    
    var panScrollable: UIScrollView? {
        return nil
    }

    var topOffset: CGFloat {
        return 0.0
    }

    var springDamping: CGFloat {
        return 1.0
    }

    var transitionDuration: Double {
        return 0.4
    }

    var transitionAnimationOptions: UIView.AnimationOptions {
        return [.allowUserInteraction, .beginFromCurrentState]
    }

    var shouldRoundTopCorners: Bool {
        return false
    }

    var showDragIndicator: Bool {
        return false
    }
}
class YouTubeViewController: UIViewController {

    @IBOutlet weak var btnSubmi: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSubmi.layer.cornerRadius = btnSubmi.frame.size.height/2
        btnSubmi.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func doClose(_ sender: Any) {
        dismiss(animated: true)
    }
}
