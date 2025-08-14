//
//  OnboardingViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 6/2/25.
//

import UIKit
import StoreKit
class OnboardingViewController: UIViewController {

    @IBOutlet weak var btnGetStart: UIButton!
    @IBOutlet weak var cltOnboarding: UICollectionView!
    private var arrOnboardings = [OnboardingModel]()
    private var indexPage = 0
    private var isShowRate: Bool = false
    @IBOutlet var arrDots: [UIImageView]!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func doStart(_ sender: Any) {
        if indexPage == arrOnboardings.count - 1 {
            AppSetings.shared.updateOnboarding()
            AppDelegate.shared.initHome()
            AnalyticsManager.shared.trackEvent(.Onboarding_Completed)
        }
        else{
            cltOnboarding.scrollToItem(at: IndexPath.init(row: indexPage + 1, section: 0), at: .right, animated: true)
            
        }
    }
    
    
    private func updatePageControl(){
        for imgV in arrDots{
            if imgV.tag == indexPage{
                imgV.image = UIImage(named: "dot2")
            }
            else{
                imgV.image = UIImage(named: "dot1")
            }
        }
    }
    
    private func showRateApp(){
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}


extension OnboardingViewController{
    private func setupUI(){
        btnGetStart.layer.cornerRadius = btnGetStart.frame.size.height/2
        btnGetStart.layer.masksToBounds = true
        cltOnboarding.registerNibCell(identifier: "OnboardingCollectionViewCell")
        arrOnboardings = [
            OnboardingModel.init(image: UIImage.init(named: "slide1") ?? UIImage.init(), title: "Instant transcription for audio and video", desc: "Fast AI Note-Taking, Convert Anything to Text in Seconds"),
            OnboardingModel.init(image: UIImage.init(named: "slide2") ?? UIImage.init(), title: "Transcribe Anything", desc: "From Files, Audios or even Youtube Videos"),
            OnboardingModel.init(image: UIImage.init(named: "slide3") ?? UIImage.init(), title: "AI Text Editing", desc: "Unlock powerful AI tools to quickly edit and transform your transcribed text."),
            OnboardingModel.init(image: UIImage.init(named: "slide4") ?? UIImage.init(), title: "Support Multi Languages", desc: "Transcribe in 100+ Languages AI-Powered Support for Multilingual Users"),
           // OnboardingModel.init(image: UIImage.init(named: "slide5") ?? UIImage.init(), title: "Help us grow!", desc: "Transcribe in 100+ Languages AI-Powered Support for Multilingual Users")
        ]
    }
}

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrOnboardings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cltOnboarding.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionViewCell", for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(arrOnboardings[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cltOnboarding.frame.size.width, height: cltOnboarding.frame.size.height)
    }
}

extension OnboardingViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x / witdh
        let roundedIndex = round(index)
        indexPage = Int(roundedIndex)
        updatePageControl()
      
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        indexPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
//        if indexPage == arrOnboardings.count - 1{
//            if !isShowRate{
//                isShowRate = true
//                showRateApp()
//            }
//        }
    }
}
