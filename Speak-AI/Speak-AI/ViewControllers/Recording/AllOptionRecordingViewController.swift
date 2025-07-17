//
//  AllOptionRecordingViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 7/2/25.
//

import UIKit
import PanModal

extension AllOptionRecordingViewController: PanModalPresentable {
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

class AllOptionRecordingViewController: UIViewController {
    var tapAction:((_ action: ActionAI)->())?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func doAction(_ sender: Any) {
        guard let btn = sender as? UIButton else{
            return
        }
       
        self.dismiss(animated: true) {
           
            self.tapAction?(ActionAI(rawValue: btn.tag) ?? .none)
        }
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
