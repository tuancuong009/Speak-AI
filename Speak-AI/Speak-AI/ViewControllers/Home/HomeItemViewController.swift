//
//  HomeItemViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 5/3/25.
//

import UIKit
import PanModal
class HomeItemViewController: UIViewController {
    var tapHideKeyboard:(()->())?
    private var groupedRecords: [String: [RecordsObj]] = [:] // Grouped data
    private var sectionTitles: [String] = []
    @IBOutlet weak var tblConnt: UITableView!
    @IBOutlet weak var viewEmpty: UIView!
    @IBOutlet weak var lblTitleNoData: UILabel!
    @IBOutlet weak var lblDescNoData: UILabel!
    var folderModel: FolderObj?
    var homeVC: HomeViewController?
    var isSetUp = false
    override func viewDidLoad() {
        super.viewDidLoad()
        isSetUp = true
        tblConnt.registerNibCell(identifier: "HomeTableViewCell")
        tblConnt.registerNibCell(identifier: "HeaderHomeTableViewCell")
        getData(nil)
        registerNotification()
        // Do any additional setup after loading the view.
    }


    @objc func getData(_ searchText: String?){
        if let folderModel = folderModel{
            if folderModel.name == "All" && folderModel.order == 1{
                groupedRecords = CoreDataManager.shared.fetchAllRecordsGroupedByHumanReadableDate(searchText: searchText)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                sectionTitles = groupedRecords.keys.sorted {
                    guard let date1 = dateFormatter.date(from: $0),
                          let date2 = dateFormatter.date(from: $1) else {
                        return $0 > $1 // fallback
                    }
                    return date1 > date2
                }
                tblConnt.reloadData()
            }
            else{
                groupedRecords = CoreDataManager.shared.fetchAllRecordsGroupedByFolder(folderId: folderModel.id, searchText: searchText)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd" 
                sectionTitles = groupedRecords.keys.sorted {
                    guard let date1 = dateFormatter.date(from: $0),
                          let date2 = dateFormatter.date(from: $1) else {
                        return $0 > $1 // fallback
                    }
                    return date1 > date2
                }
                tblConnt.reloadData()
            }
        }
        if searchText == nil{
            viewEmpty.isHidden = groupedRecords.count == 0 ? false : true
        }
        else{
            viewEmpty.isHidden = groupedRecords.count == 0 ? false : true
        }
        
        updateTextNoData(searchText)
    }

    private func updateTextNoData(_ searchText: String?){
        lblTitleNoData.text = searchText == nil ? "You don’t have any notes" : "No notes found"
        lblDescNoData.isHidden = searchText == nil ? false : true
    }
    private func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(getDataNotification), name: NSNotification.Name(rawValue: NotificationDefineName.NEW_RECORD), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getSearchData( _:)), name: NSNotification.Name(rawValue: NotificationDefineName.SEARCH_HOME), object: nil)
    }
    
    @objc func getDataNotification(){
        if let folderModel = folderModel{
            if folderModel.name == "All" && folderModel.order == 1{
                groupedRecords = CoreDataManager.shared.fetchAllRecordsGroupedByHumanReadableDate(searchText: nil)
                sectionTitles = groupedRecords.keys.sorted(by: { $0 < $1 }) // Sort sections
                tblConnt.reloadData()
            }
            else{
                groupedRecords = CoreDataManager.shared.fetchAllRecordsGroupedByFolder(folderId: folderModel.id, searchText: nil)
                sectionTitles = groupedRecords.keys.sorted(by: { $0 < $1 }) // Sort sections
                tblConnt.reloadData()
            }
        }
        viewEmpty.isHidden = groupedRecords.count == 0 ? false : true
        updateTextNoData(nil)
    }
    
    @objc func getSearchData(_ notification: Notification){
        if let search = notification.object as? String{
            getData(search)
        }
        else{
            getData(nil)
        }
        
    }
}
extension HomeItemViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sectionTitles[section]
        return groupedRecords[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblConnt.dequeueReusableCell(withIdentifier: "HomeTableViewCell") as! HomeTableViewCell
        let key = sectionTitles[indexPath.section]
        if let record =  groupedRecords[key]?[indexPath.row]{
            cell.configCell(record: record)
        }
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tblConnt.dequeueReusableCell(withIdentifier: "HeaderHomeTableViewCell") as! HeaderHomeTableViewCell
        cell.lblheader.text = sectionTitles[section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == sectionTitles.count - 1 ? 60 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: section == sectionTitles.count - 1 ? 60 : 0))
        return footer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = sectionTitles[indexPath.section]
        if let record =  groupedRecords[key]?[indexPath.row]{
//            let detailVC = DetailHomeViewController.instantiate()
//            detailVC.modalPresentationStyle = .fullScreen
//            detailVC.folderObj = CoreDataManager.shared.getInfoFolder(withID: record.folderId)
//            detailVC.recordObj = record
//            detailVC.mergeAudioURL = FileManagerHelper.shared.getFile(fileName: record.file, folderName: FILE_NAME.records)
//            self.homeVC?.present(detailVC, animated: true)
            
            let detailVC = DetailRecordingViewController.instantiate()
            detailVC.folderObj = CoreDataManager.shared.getInfoFolder(withID: record.folderId)
            detailVC.recordObj = record
            detailVC.mergeAudioURL = FileManagerHelper.shared.getFile(fileName: record.file, folderName: FILE_NAME.records)
            let rowVC: PanModalPresentable.LayoutType = detailVC
            self.homeVC?.presentPanModal(rowVC)
        }
        
       
    }
}


extension HomeItemViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tapHideKeyboard?()
    }
}
