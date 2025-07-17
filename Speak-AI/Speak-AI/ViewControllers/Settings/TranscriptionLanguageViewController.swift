//
//  TranscriptionLanguageViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 7/2/25.
//

import UIKit

class TranscriptionLanguageViewController: UIViewController {

    @IBOutlet weak var tblLanguage: UITableView!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet var lblHeader: UILabel!
    @IBOutlet var viewLanguage: UIView!
    var languageCode = ""
    var languageSections = [LanguageModel]()
    var languageMoreSections = [LanguageModel]()
    var allLanguages = [LanguageModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    @IBAction func doBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func doSelect(_ sender: Any) {
        AppSetings.shared.updateLanguageDefault(languageCode)
        navigationController?.popViewController(animated: true)
    }
}




extension TranscriptionLanguageViewController{
    private func setupUI(){
        tblLanguage.registerNibCell(identifier: "LanguageTableViewCell")
        btnSelect.layer.cornerRadius = btnSelect.frame.size.height/2
        btnSelect.layer.masksToBounds = true
        languageCode = AppSetings.shared.getLanguageDefault()
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
        return locale.regionCode
    }
    
}
extension TranscriptionLanguageViewController: UITableViewDataSource, UITableViewDelegate{
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
        cell.lblName.font = UIFont(name: languageModel.code == languageCode ? "Inter-Semibold": "Inter-Regular", size: 16)
        cell.imgFlat.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            languageCode = languageSections[indexPath.row].code
            // AppSetings.shared.updateLanguageDefault(languageCode)
            tblLanguage.reloadData()
        }
        else{
            languageCode = languageMoreSections[indexPath.row].code
            tblLanguage.reloadData()
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
        return viewLanguage
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }
}
