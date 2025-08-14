//
//  FolderViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 4/3/25.
//

import UIKit
import SwiftReorder
import PanModal
extension FolderViewController: PanModalPresentable {
    // 🔹 Disable swipe-to-dismiss
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
        return true
    }
    
    func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return false
    }
    
    var panScrollable: UIScrollView? {
        return tblFolder
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
        return true
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(view.bounds.height * 0.9)
    }

    var longFormHeight: PanModalHeight {
        return .contentHeight(view.bounds.height * 0.9)
    }
}


class FolderViewController: UIViewController {
    var tapEditFolder:((_ folders: [FolderObj])->())?
    var tapAddfolder:((_ folder: FolderObj)->())?
    var tapDeleteFolder:((_ folders: [FolderObj])->())?
    var folders = [FolderObj]()
    var folderWorkings = [FolderObj]()
    var folderFirts: FolderObj?
    var tapReoders:((_ folders: [FolderObj])->())?
    @IBOutlet weak var tblFolder: UITableView!
    @IBOutlet weak var lblDesc: UILabel!
    private var footerHomeCell: FooterFolderTableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func doClose(_ sender: Any) {
        // dismiss(animated: true)
        APP_DELEGATE.initHome()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
       
        
    }
}

extension FolderViewController{
    private func setupUI(){
        tblFolder.registerNibCell(identifier: "FolderTableViewCell")
        tblFolder.registerNibCell(identifier: "FooterFolderTableViewCell")
        //tblFolder.allowsSelection = false
        tblFolder.sectionHeaderTopPadding = 0.0
        tblFolder.reorder.delegate = self
        folderWorkings = folders
        folderWorkings.remove(at: 0)
        tblFolder.reloadData()
    }
}


extension FolderViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderWorkings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        
        let cell = tblFolder.dequeueReusableCell(withIdentifier: "FolderTableViewCell") as! FolderTableViewCell
        cell.btnDone.isHidden = true
        cell.txfName.isEnabled = false
        cell.txfName.textColor = .init(hexString: "030712")
        cell.txfName.text = folderWorkings[indexPath.row].name
        cell.tapDone = { [] value in
            self.folderWorkings[indexPath.row].name = value
            cell.btnDone.isHidden = true
            cell.txfName.isEnabled = false
            self.tapEditFolder?(self.folderWorkings)
            _ = CoreDataManager.shared.updateNameFolder(withID:  self.folderWorkings[indexPath.row].id, name: value)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DIDSELECT")
        tblFolder.reloadData()
        let seconds = 0.25
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in
            if let cell = tblFolder.cellForRow(at: indexPath) as? FolderTableViewCell{
                cell.btnDone.isHidden = false
                cell.txfName.isEnabled = true
                cell.txfName.becomeFirstResponder()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let foderModel = self.folderWorkings[indexPath.row]
            let success = CoreDataManager.shared.deleteFolder(withID: foderModel.id)
            if let folderFirts = self.folderFirts{
                CoreDataManager.shared.updateAllRecordFromFolderToFolderAll(folderId: foderModel.id, folderMoveId: folderFirts.id)
            }
            print(success ? "Deleted" : "Failed to delete")
            self.folderWorkings.remove(at: indexPath.row)
            tableView.reloadData()
            self.tapDeleteFolder?(self.folderWorkings)
            NotificationCenter.default.post(name: NSNotification.Name(NotificationDefineName.NEW_RECORD), object: nil)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
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
        
        let cell = tblFolder.dequeueReusableCell(withIdentifier: "FooterFolderTableViewCell") as! FooterFolderTableViewCell
        cell.btnDone.isHidden = true
        cell.txfName.isEnabled = false
        cell.txfName.textColor = .red
        cell.imgAdd.isHidden = false
        cell.txfName.text = "New Folder"
        cell.btnAddNew.isHidden = false
        cell.statusBtnDone("")
        cell.btnDone.addTarget(self, action: #selector(doDoneFooter), for: .touchUpInside)
        cell.btnAddNew.addTarget(self, action: #selector(doAddNew), for: .touchUpInside)
        cell.tapEndEditing = { [] in
            self.tblFolder.reloadData()
        }
        footerHomeCell = cell
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 50
    }
    
    @objc func doDoneFooter(){
        print("doDoneFooter")
        let folderModel = FolderObj(id: UUID().uuidString, name: footerHomeCell.txfName.text!.trimmed, order: folderWorkings.count + 1)
        AnalyticsManager.shared.trackEvent(.Folder_Created, properties: [AnalyticsProperty.folderName: footerHomeCell.txfName.text!.trimmed])
        if let folderID = CoreDataManager.shared.saveFolder(folderObj: folderModel) {
            print("Folder saved with ID: \(folderID)")
        } else {
            print("Failed to save folder")
        }
        folderWorkings.append(folderModel)
        self.tapAddfolder?(folderModel)
       if let cell = footerHomeCell
        {
           cell.btnDone.isHidden = true
           cell.txfName.isEnabled = false
           cell.txfName.textColor = .red
           cell.imgAdd.isHidden = false
           cell.txfName.text = "New Folder"
           cell.btnAddNew.isHidden = false
           cell.statusBtnDone("")
       }
        tblFolder.reloadData()
        
    }
    
    @objc func doAddNew(){
        print("doAddNew")
        tblFolder.reloadData()
        let seconds = 0.25
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

extension FolderViewController: TableViewReorderDelegate {
    
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("sourceIndexPath--->",sourceIndexPath.row)
        print("destinationIndexPath--->",destinationIndexPath.row)
        let item = folderWorkings[sourceIndexPath.row]
        folderWorkings.remove(at: sourceIndexPath.row)
        folderWorkings.insert(item, at: destinationIndexPath.row)
        
        CoreDataManager.shared.updateFolderOrderInCoreData(self.folderWorkings)
        self.tapReoders?(self.folderWorkings)
    }
    
}

