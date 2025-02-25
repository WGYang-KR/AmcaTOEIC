//
//  SwipeCardCompletionPopUpVC.swift
//  SwipeHanja
//
//  Created by WG-Yang on 5/14/24.
//

import UIKit

class SwipeCardCompletionPopUpVC: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bottomButton: UIButton!
    
    @IBOutlet var containerCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var containerHidingBottomConstraint: NSLayoutConstraint!
    
    var completionClosure: (() -> Void)?
    
    enum ScreenType {
        case fromNormalStudy
        case fromFavoritesStudy
    }
    var screenType: ScreenType = .fromNormalStudy
    
    func configure(screenType: ScreenType = .fromNormalStudy, completion: (() -> Void)? ) {
        self.screenType = screenType
        self.completionClosure = completion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showView()
    }
    
    @IBAction func bottomButtonTapped(_ sender: Any) {
        resignView {
            self.moveBackVC(animated: false) {
                self.completionClosure?()
            }
        }
    }
    
    func initView() {
        containerView.layer.cornerRadius = 16
        bottomButton.layer.cornerRadius = 16
        setUI(shows: false)
        titleLabel.text = "학습 완료"
        switch screenType {
        case .fromNormalStudy:
            messageLabel.text = "축하해요! 학습을 모두 마쳤습니다.\n다음 챕터로 이동하여 학습을 계속해 주세요."
        case .fromFavoritesStudy:
            messageLabel.text = "축하해요! 학습을 모두 마쳤습니다.\n학습기록이 초기화 됩니다."
        }

        bottomButton.setTitle("확인", for: .normal)
    }
    
    func showView() {
            self.setUI(shows: true)
    }
    
    func resignView(completion: (() -> Void)? ) {
        self.setUI(shows: false)
        completion?()
    }
    
    func setUI(shows: Bool ) {
        if shows {
            UIView.animate(withDuration: 0.2) {
                self.view.backgroundColor = .colorOverlayBackground
            }
        } else {
            self.view.backgroundColor = .clear
        }
        
        if shows {
            let transition = CATransition()
            transition.duration = 0.2
            transition.type = .push
            transition.subtype = .fromTop
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            containerView.layer.add(transition, forKey: kCATransition)
        } else {
            containerView.layer.removeAllAnimations()
        }
        
        self.view.backgroundColor = shows ? .colorOverlayBackground : .clear
        self.containerCenterYConstraint.isActive = shows
        self.containerHidingBottomConstraint.isActive = !shows
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
