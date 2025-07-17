//
//  FolderTableViewCell.swift
//  Speak-AI
//
//  Created by QTS Coder on 4/3/25.
//

import UIKit

class FolderTableViewCell: UITableViewCell {
    var tapDone:((_ value: String)->())?
    @IBOutlet weak var txfName: UITextField!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var icReorder: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func doDone(_ sender: Any) {
        self.tapDone?(txfName.text!.trimmed)
    }
    
    func statusBtnDone(_ text: String){
        if text.trimmed.isEmpty{
            btnDone.isEnabled = false
            btnDone.alpha = 0.2
        }
        else{
            btnDone.isEnabled = true
            btnDone.alpha = 1
        }
    }
}
extension FolderTableViewCell: UITextFieldDelegate{
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        self.statusBtnDone(newText)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txfName.resignFirstResponder()
        return true
    }
}

