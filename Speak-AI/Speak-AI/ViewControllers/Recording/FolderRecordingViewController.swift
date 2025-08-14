//
//  FolderRecordingViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 5/3/25.
//

import UIKit

class FolderRecordingViewController: UIViewController {
    var tapFolder:((_ folder: FolderObj)->())?
    private var folders = [FolderObj]()
    @IBOutlet weak var tblFolders: UITableView!
    private var footerHomeCell: FooterFolderTableViewCell!
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

    @IBAction func doClose(_ sender: Any) {
        dismiss(animated: true)
    }
}
extension FolderRecordingViewController{
    private func setupUI(){
        tblFolders.registerNibCell(identifier: "FolderTableViewCell")
        tblFolders.registerNibCell(identifier: "FooterFolderTableViewCell")
        tblFolders.isEditing = false
        tblFolders.sectionHeaderTopPadding = 0.0
        folders = CoreDataManager.shared.fecthAllFolders()
        tblFolders.reloadData()
    }
}


extension FolderRecordingViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblFolders.dequeueReusableCell(withIdentifier: "FolderTableViewCell") as! FolderTableViewCell
        cell.btnDone.isHidden = true
        cell.txfName.isEnabled = false
        cell.icReorder.isHidden = true
        cell.txfName.textColor = .init(hexString: "030712")
        cell.txfName.text = folders[indexPath.row].name
        cell.tapDone = { [] value in
          
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapFolder?(folders[indexPath.row])
        dismiss(animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let cell = tblFolders.dequeueReusableCell(withIdentifier: "FooterFolderTableViewCell") as! FooterFolderTableViewCell
        cell.btnDone.isHidden = true
        cell.txfName.isEnabled = false
        cell.txfName.textColor = .red
        cell.imgAdd.isHidden = false
        cell.txfName.text = "New Folder"
        cell.btnAddNew.isHidden = false
        cell.statusBtnDone("")
        cell.btnDone.addTarget(self, action: #selector(doDoneFooter), for: .touchUpInside)
        cell.btnAddNew.addTarget(self, action: #selector(doAddNew), for: .touchUpInside)
        footerHomeCell = cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
       
        return 50
    }
    
    @objc func doDoneFooter(){
        let folderModel = FolderObj(id: UUID().uuidString, name: footerHomeCell.txfName.text!.trimmed, order: folders.count + 1)
        AnalyticsManager.shared.trackEvent(.Folder_Created, properties: [AnalyticsProperty.folderName: footerHomeCell.txfName.text!.trimmed])
        if let folderID = CoreDataManager.shared.saveFolder(folderObj: folderModel) {
            print("Folder saved with ID: \(folderID)")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyDefaults.newFolder), object: folderModel)
        } else {
            print("Failed to save folder")
        }
        folders.append(folderModel)
        tblFolders.reloadData()
        
    }
    
    @objc func doAddNew(){
        tblFolders.reloadData()
        let seconds = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in
            footerHomeCell.btnAddNew.isHidden = true
            footerHomeCell.txfName.text = nil
            footerHomeCell.txfName.placeholder = "New Folder Title"
            footerHomeCell.txfName.textColor = .init(hexString: "030712")
            footerHomeCell.imgAdd.isHidden = true
            footerHomeCell.btnDone.isHidden = false
            footerHomeCell.txfName.isEnabled = true
            footerHomeCell.txfName.becomeFirstResponder()
            footerHomeCell.statusBtnDone("")
        }
        
    }
}
