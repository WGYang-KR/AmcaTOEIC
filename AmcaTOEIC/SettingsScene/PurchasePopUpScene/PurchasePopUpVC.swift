//
//  PurchasePopUpVC.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 1/5/25.
//

import UIKit
import SwiftUI

struct PurchasePopUpViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> PurchasePopUpVC {
        let viewController = PurchasePopUpVC()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve // 부드러운 페이드 효과
        viewController.view.backgroundColor = UIColor.clear
        viewController.onDismiss = {
            isPresented = false
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: PurchasePopUpVC, context: Context) {}
}

class PurchasePopUpVC: UIViewController {
    @IBOutlet var backBoxView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    
    var baseVC: UIViewController?
    
    var onDismiss: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backBoxView.layer.cornerRadius = 12.0
        priceLabel.text = "가격: 3,300원 (평생 소장)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor(resource: .colorOverlayBackground)
        }
    }
    @IBAction func closeSelected(_ sender: Any) {
        if let onDismiss {
            onDismiss()
        } else {
            dismiss(animated: false)
        }
    }
    
    @IBAction func goToBuySelected(_ sender: Any) {
//        let appStoreURL = URL(string: "https://apps.apple.com/app/hashcamera/id6502834553")!
//        if UIApplication.shared.canOpenURL(appStoreURL) {
//            UIApplication.shared.open(appStoreURL)
//        }
//        dismiss(animated: false)
        
        //TODO: 인앱결제하기
    }
    
}
