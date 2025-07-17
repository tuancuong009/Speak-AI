//
//  OptionRecordingViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 7/2/25.
//

import UIKit
import PanModal
extension OptionRecordingViewController: PanModalPresentable {
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

class OptionRecordingViewController: UIViewController{
    var tapOption:((_ action: ActionMore)->())?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func doClose(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func doAction(_ sender: Any) {
        guard let btn = sender as? UIButton else{
            return
        }
        dismiss(animated: true) {
            self.tapOption?(ActionMore(rawValue: btn.tag) ?? .moveFolder)
        }
    }
}
