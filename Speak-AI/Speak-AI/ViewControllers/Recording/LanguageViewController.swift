//
//  LanguageViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 5/3/25.
//

import UIKit
import FlagKit
class LanguageViewController: UIViewController {
    var tapLanguage:((_ language: LanguageModel, _ index: Int)->())?
    @IBOutlet weak var tblLanguage: UITableView!
    @IBOutlet weak var txfSearch: UITextField!
    var languageCode = ""
    var languageSections = [LanguageModel]()
    var languageMoreSections = [LanguageModel]()
    var allLanguages = [LanguageModel]()
    var languageModel: LanguageModel?
    @IBOutlet var viewHeader: UIView!
    @IBOutlet var lblHeader: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func doClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension LanguageViewController{
    private func setupUI(){
        tblLanguage.sectionHeaderTopPadding = 0
        languageCode = languageModel?.code ?? ""
        tblLanguage.registerNibCell(identifier: "LanguageTableViewCell")
        allLanguages = LanguageAssemblyAI.shared.listLanguageSupport()
        languageSections.removeAll()
        languageMoreSections.removeAll()
        for arr in allLanguages {
            if arr.img.isEmpty{
                languageMoreSections.append(arr)
            }
            else{
                languageSections.append(arr)
            }
        }
        tblLanguage.reloadData()
    }
    
    func countryCode(from languageCode: String) -> String? {
        let locale = Locale(identifier: languageCode)
        return locale.regionCode // Trả về mã quốc gia (ISO 3166-1 alpha-2) nếu có
    }
    
}
extension LanguageViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return languageSections.count
        }
        return languageMoreSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tblLanguage.dequeueReusableCell(withIdentifier: "LanguageTableViewCell") as! LanguageTableViewCell
            let languageModel = languageSections[indexPath.row]
            cell.lblName.text = languageModel.name
            cell.imgFlat.image = UIImage.init(named: languageModel.img)
            cell.imgFlat.isHidden = false
            cell.bgCell.image = languageModel.code == languageCode ? UIImage.init(named: "selected") : UIImage.init(named: "select")
            cell.icSelect.isHidden = languageModel.code == languageCode ? false : true
            cell.lblName.font = UIFont(name: languageModel.code == languageCode ? "Inter-Semibold": "Inter-Regular", size: 16)
            return cell
        }
        let cell = tblLanguage.dequeueReusableCell(withIdentifier: "LanguageTableViewCell") as! LanguageTableViewCell
        let languageModel = languageMoreSections[indexPath.row]
        cell.lblName.text = languageModel.name
        cell.bgCell.image = languageModel.code == languageCode ? UIImage.init(named: "selected") : UIImage.init(named: "select")
        cell.icSelect.isHidden = languageModel.code == languageCode ? false : true
        cell.imgFlat.isHidden = true
        cell.lblName.font = UIFont(name: languageModel.code == languageCode ? "Inter-Semibold": "Inter-Regular", size: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            languageCode = languageSections[indexPath.row].code
            // AppSetings.shared.updateLanguageDefault(languageCode)
            tblLanguage.reloadData()
            tapLanguage?(languageSections[indexPath.row], indexPath.row)
            dismiss(animated: true)
        }
        else{
            languageCode = languageMoreSections[indexPath.row].code
            //AppSetings.shared.updateLanguageDefault(languageCode)
            tblLanguage.reloadData()
            tapLanguage?(languageMoreSections[indexPath.row], indexPath.row)
            dismiss(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }
        if languageMoreSections.count == 0 {
            return 1.0
        }
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        }
        if languageMoreSections.count == 0 {
            return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        }
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }
}

extension LanguageViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txfSearch.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if updatedText.isEmpty{
            languageSections.removeAll()
            languageMoreSections.removeAll()
            for arr in allLanguages {
                if arr.img.isEmpty{
                    languageMoreSections.append(arr)
                }
                else{
                    languageSections.append(arr)
                }
            }
        }
        else{
            languageSections.removeAll()
            languageMoreSections.removeAll()
            
            for arr in allLanguages {
                if arr.name.lowercased().contains(updatedText.lowercased()) {
                    if arr.img.isEmpty {
                        languageMoreSections.append(arr)
                    } else {
                        languageSections.append(arr)
                    }
                }
            }
        }
        
        
        tblLanguage.reloadData()
        
        return true
    }
}
