//
//  WebViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 21/4/25.
//

import UIKit
import WebKit
class WebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var wkWebView: WKWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var url: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        wkWebView.navigationDelegate = self
        loadWeb()
        // Do any additional setup after loading the view.
    }


    private func loadWeb(){
        indicator.startAnimating()
        if let url = url{
            let request = URLRequest(url: url)
            wkWebView.load(request)
        }
    }

    @IBAction func doBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // Called when load finishes
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            indicator.isHidden = true
        }
}
