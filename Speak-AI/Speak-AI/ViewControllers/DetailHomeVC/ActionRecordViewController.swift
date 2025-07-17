//
//  ActionRecordViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 20/3/25.
//

import UIKit
import Alamofire
class ActionRecordViewController: BaseViewController, PagerAwareProtocol {
    var pageDelegate: (any BottomPageDelegate)?
    
    var currentViewController: UIViewController?
    
    var pagerTabHeight: CGFloat? {
        return 50
    }
    var recordObj: RecordsObj?
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var cltMenu: UICollectionView!
    var pageMenu: CAPSPageMenu?
    var controllers: [UIViewController] = []
    private var arrMenus: [ActionAI] = [.transcription]
    var arrControllerTabs: [TranscripitonViewController] = []
    private var indexMenu = 0
    var recordId =  ""
    var detailHomeViewController: DetailHomeViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
    
    func addNewPage(action: ActionAI, desc: String, isMove: Bool = false) {
        arrMenus.append(action)
        cltMenu.reloadData()
        let tabModel = tabDetailOpenAI()
        tabModel.action = action
        tabModel.general = desc
        tabModel.desc = desc
        
        let transcuibeVC  = TranscripitonViewController()
        transcuibeVC.detailHomeViewController = self.detailHomeViewController
        transcuibeVC.tabDetailOpenAI = tabModel
        transcuibeVC.action = action
        transcuibeVC.recordId = recordId
        arrControllerTabs.append(transcuibeVC)
        pageMenu?.view.removeFromSuperview()
        
        // Khởi tạo lại PageMenu với danh sách mới
        let parameters: [CAPSPageMenuOption] = [
            .menuMargin(0),
            .menuItemSeparatorPercentageHeight(0.0),
            .menuHeight(0),
            .titleTextSizeBasedOnMenuItemWidth(true),
        ]
        pageMenu = CAPSPageMenu(viewControllers: arrControllerTabs, frame: CGRect(x: 0, y: 0, width: viewContent.frame.size.width, height: viewContent.frame.size.height), pageMenuOptions: parameters)
        
        pageMenu!.delegate = self
        pageMenu?.controllerScrollView.isScrollEnabled = true
        viewContent.addSubview(pageMenu!.view)
        print("arrControllerTabs--->",arrControllerTabs.count)
        if isMove{
            pageMenu?.moveToPage(arrMenus.count - 1)
        }
    }
    
    func setUpPageMenu()
    {
        arrControllerTabs.removeAll()
        for item in arrMenus{
            let tabModel = tabDetailOpenAI()
            tabModel.action = item
            let transcuibeVC  = TranscripitonViewController()
            transcuibeVC.action = item
            transcuibeVC.recordId = recordId
            transcuibeVC.tabDetailOpenAI = tabModel
            arrControllerTabs.append(transcuibeVC)
            
        }
        
        let parameters: [CAPSPageMenuOption] = [
            .menuMargin(0),
            .menuItemSeparatorPercentageHeight(0.0),
            .menuHeight(0),
            .titleTextSizeBasedOnMenuItemWidth(true),
        ]
        self.pageMenu = CAPSPageMenu(viewControllers: arrControllerTabs, frame: CGRect(x: 0, y: 0, width: viewContent.frame.size.width, height: viewContent.frame.size.height), pageMenuOptions: parameters)
        
        pageMenu!.delegate = self
        pageMenu?.controllerScrollView.isScrollEnabled = true
        viewContent.addSubview(pageMenu!.view)
        
        self.pageDelegate?.tp_pageViewController(arrControllerTabs[indexMenu], didSelectPageAt: indexMenu)
    }

    func setUpPageMenuAllActionLocals(recordActions: [RecordActionObj])
    {
        arrControllerTabs.removeAll()
        arrMenus.removeAll()
        for item in recordActions{
            arrMenus.append(ActionAI(rawValue: item.action) ?? .transalte)
            let tabModel = tabDetailOpenAI()
            tabModel.action = ActionAI(rawValue: item.action) ?? .transalte
            tabModel.desc = item.text
            tabModel.general = item.textAI
            
            let transcuibeVC  = TranscripitonViewController()
            transcuibeVC.detailHomeViewController = self.detailHomeViewController
            transcuibeVC.action = ActionAI.init(rawValue: item.action) ?? .transalte
            transcuibeVC.recordId = recordId
            transcuibeVC.tabDetailOpenAI = tabModel
            arrControllerTabs.append(transcuibeVC)
            
        }
        cltMenu.reloadData()
        let parameters: [CAPSPageMenuOption] = [
            .menuMargin(0),
            .menuItemSeparatorPercentageHeight(0.0),
            .menuHeight(0),
            .titleTextSizeBasedOnMenuItemWidth(true),
        ]
        self.pageMenu = CAPSPageMenu(viewControllers: arrControllerTabs, frame: CGRect(x: 0, y: 0, width: viewContent.frame.size.width, height: viewContent.frame.size.height), pageMenuOptions: parameters)
        
        pageMenu!.delegate = self
        pageMenu?.controllerScrollView.isScrollEnabled = true
        viewContent.addSubview(pageMenu!.view)
        if indexMenu <= arrControllerTabs.count - 1{
            self.pageDelegate?.tp_pageViewController(arrControllerTabs[indexMenu], didSelectPageAt: indexMenu)
        }
        
    }
    
    func validActionTab(action: ActionAI){
        if let index = arrMenus.firstIndex(of: action) {
            print("Index is \(index)")  // Output: Index of 30 is 2
            pageMenu?.moveToPage(index)
        } else {
            print("Not found")
            showBusy()
            getSummary(action: action) { value in
                self.hideBusy()
                if let value = value{
                    self.addNewPage(action: action, desc: value, isMove: true)
                    if let detailHomeViewController = self.detailHomeViewController{
                        detailHomeViewController.saveRecordAction(action: action, text: value)
                    }
                }
            }
        }
    }
    
    private func getSummary(action: ActionAI, completion: @escaping (String?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(ConfigAOpenAI.Summaries)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are an expert summarizer."],
                ["role": "user", "content": action.promptFormat(text: detailHomeViewController?.transcriptionText ?? "")]
            ],
            "temperature": 0.5
        ]
        print("Param--->",parameters)
        AF.request(ConfigAOpenAI.url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .downloadProgress { progress in
               
                
            }
            .responseDecodable(of: OpenAIResponse.self) { response in
                switch response.result {
                case .success(let openAIResponse):
                    if let summary = openAIResponse.choices.first?.message.content {
                        print("✅ Summary: \(summary)")
                        completion(summary)
                    } else {
                        print("❌ No summary found")
                        completion(nil)
                    }
                case .failure(let error):
                    print("❌ Error: \(error)")
                    completion(nil)
                }
            }
    }
}

extension ActionRecordViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrMenus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cltMenu.dequeueReusableCell(withReuseIdentifier: "MenuHomeCollect", for: indexPath) as! MenuHomeCollect
        cell.lblname.text = arrMenus[indexPath.row].name
        cell.viewSelect.isHidden = indexPath.row == indexMenu ? false : true
        cell.lblname.font = UIFont(name: indexPath.row == indexMenu ? "Inter-SemiBold" : "Inter-Regular", size: 14.0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        indexMenu = indexPath.row
        cltMenu.reloadData()
        cltMenu.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageMenu?.moveToPage(indexMenu)
        if indexMenu <= arrControllerTabs.count - 1{
            self.pageDelegate?.tp_pageViewController(arrControllerTabs[indexMenu], didSelectPageAt: indexMenu)
        }
    }
}
extension ActionRecordViewController: CAPSPageMenuDelegate{
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        indexMenu = index
        cltMenu.reloadData()
        cltMenu.scrollToItem(at: IndexPath(row: indexMenu, section: 0), at: .centeredHorizontally, animated: true)
        if var recordObj = recordObj, !recordObj.is_read{
            recordObj.is_read = true
            _ = CoreDataManager.shared.updateReadRecord(withID: recordObj.id)
        }
        
        else{
            _ = CoreDataManager.shared.updateReadRecord(withID: self.detailHomeViewController?.recordId ?? "")
        }
        self.pageDelegate?.tp_pageViewController(arrControllerTabs[indexMenu], didSelectPageAt: indexMenu)
    }
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        
    }
}
