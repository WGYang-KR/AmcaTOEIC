//
//  BuyPopUpVC.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 1/5/25.
//

import UIKit

class BuyPopUpVC: UIViewController {
    @IBOutlet var backBoxView: UIView!
    var baseVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backBoxView.layer.cornerRadius = 12.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor(resource: .colorOverlayBackground)
        }
    }
    @IBAction func closeSelected(_ sender: Any) {
        dismiss(animated: false)
    }
    
    @IBAction func goToBuySelected(_ sender: Any) {
        let appStoreURL = URL(string: "https://apps.apple.com/app/hashcamera/id6502834553")!
        if UIApplication.shared.canOpenURL(appStoreURL) {
            UIApplication.shared.open(appStoreURL)
        }
        dismiss(animated: false)
    }
    
}
