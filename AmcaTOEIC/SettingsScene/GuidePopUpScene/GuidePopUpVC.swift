//
//  PurchasePopUpVC.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 1/5/25.
//

import UIKit
import SwiftUI

struct GuidePopUpViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> GuidePopUpVC {
        let viewController = GuidePopUpVC()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve // 부드러운 페이드 효과
        viewController.view.backgroundColor = UIColor.clear
        viewController.onDismiss = {
            isPresented = false
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: GuidePopUpVC, context: Context) {}
}

class GuidePopUpVC: UIViewController {
    @IBOutlet var backBoxView: UIView!

    var baseVC: UIViewController?
    
    var onDismiss: (() -> Void)?
    
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

    @IBAction func confirmSelected(_ sender: Any) {
        if let onDismiss {
            onDismiss()
        } else {
            dismiss(animated: false)
        }
    }
    
}
