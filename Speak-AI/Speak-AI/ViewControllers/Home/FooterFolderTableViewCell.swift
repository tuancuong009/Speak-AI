//
//  FooterFolderTableViewCell.swift
//  Speak-AI
//
//  Created by QTS Coder on 4/3/25.
//

import UIKit

class FooterFolderTableViewCell: UITableViewCell {
    var tapEndEditing:(()->())?
    @IBOutlet weak var txfName: UITextField!
    @IBOutlet weak var imgAdd: UIImageView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnAddNew: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        txfName.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
extension FooterFolderTableViewCell: UITextFieldDelegate{
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
        self.tapEndEditing?()
        return true
    }
}
