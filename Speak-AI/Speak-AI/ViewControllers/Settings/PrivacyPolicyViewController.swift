//
//  PrivacyPolicyViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 7/2/25.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
}
