//
//  CustomLabel.swift
//  AmcaTOEIC
//
//  Created by Anto-Yang on 3/24/25.
//
import UIKit

class CustomLabel: UILabel, UIGestureRecognizerDelegate {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGesture()
    }
    
    private func setupGesture() {
        isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showMenu))
        longPress.cancelsTouchesInView = true
        self.addGestureRecognizer(longPress)
    }
    
    @objc private func showMenu(_ sender: UILongPressGestureRecognizer) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.menuItems = [UIMenuItem(title: "복사", action: #selector(copyText))]
            menu.showMenu(from: self, rect: bounds)
        }
    }
    
    @objc private func copyText() {
        UIPasteboard.general.string = text
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // 👇 이거 없으면 UILabel은 터치를 제대로 먹지 못함
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}
