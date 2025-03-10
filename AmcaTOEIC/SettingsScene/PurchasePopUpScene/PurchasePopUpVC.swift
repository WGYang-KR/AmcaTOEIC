//
//  PurchasePopUpVC.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 1/5/25.
//

import UIKit
import SwiftUI
import StoreKit

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
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    
    var baseVC: UIViewController?
    
    var onDismiss: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backBoxView.layer.cornerRadius = 12.0
        
        buyButton.isEnabled = false
        LoadingIndicator.showLoadingView()
        IAPManager.shared.getProductPrice { [weak self] product in
            LoadingIndicator.hideLoadingView()
            guard let self else { return }
            guard let product else { return }
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = product.priceLocale
            let formattedString = numberFormatter.string(from: product.price)
            
            priceLabel.text = "가격: \(formattedString ?? "-") (평생 소장)"
            
            buyButton.isEnabled = true
           
        }
       
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
        LoadingIndicator.showLoadingView()
        IAPManager.shared.buyProduct { [weak self] result in
            LoadingIndicator.hideLoadingView()
            guard let self else { return }
            switch result {
            case .success:
                NotificationCenter.default.post(name: NotiName.purchaseCompleted, object: nil)
                closeSelected(Void())
            case .failure(let error):
                AlertHelper.alertInform(baseVC: self, title: "구매에 실패하였습니다.", message: "\(error.localizedDescription)", confirmCompletion: {
                    self.closeSelected(Void())
                })
            }
        }
    }
    
}
