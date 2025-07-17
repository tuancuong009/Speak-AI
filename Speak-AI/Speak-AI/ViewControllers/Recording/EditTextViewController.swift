//
//  EditTextViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 21/2/25.
//

import UIKit
protocol EditTextViewControllerDelegate: NSObject{
    func savedText(_ text: String)
}

class EditTextViewController: BaseViewController {

    @IBOutlet weak var spaceTop: NSLayoutConstraint!
    @IBOutlet weak var tvMessage: UITextView!
    var text = ""
    weak var delegate: EditTextViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        tvMessage.text = text
        registerNotification()
        tvMessage.becomeFirstResponder()
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

    @IBAction func doCancel(_ sender: Any) {
        removeNotification()
        dismiss(animated: true)
    }
    @IBAction func doSave(_ sender: Any) {
        if self.tvMessage.text!.trimmed.isEmpty{
            self.showMessageComback("Please input the content") { success in
                
            }
        }
        else{
            removeNotification()
            self.delegate?.savedText(tvMessage.text!)
            dismiss(animated: true)
        }
        
    }
}


extension EditTextViewController{
    private func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeNotification(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc fileprivate func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let topPadding = view.safeAreaInsets.bottom
            print(topPadding)
            spaceTop.constant = keyboardSize.height
            view.layoutIfNeeded()
        }
    }
    
    @objc fileprivate func keyboardWillHide(notification: Notification) {
        spaceTop.constant = 0
        view.layoutIfNeeded()
    }
}
