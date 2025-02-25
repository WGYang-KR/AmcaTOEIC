//
//  ExampleOverlayView.swift
//  KolodaView
//
//  Created by Eugene Andreyev on 6/21/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit

private let overlayRightImageName = "circle"
private let overlayLeftImageName = "xmark"
private let overlayRightColor = UIColor.colorSwipeYes
private let overlayLeftColor = UIColor.colorSwipeNo
private let overlayRightText = "알고있음"
private let overlayLeftText = "학습필요"

class SHOverlayView: OverlayView {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet weak var overlayLabel: UILabel!
    
    override func update(progress: CGFloat) {
        alpha = progress * 0.5
    }
    
    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(systemName: overlayLeftImageName)
                backgroundView.backgroundColor = overlayLeftColor
                overlayLabel.text = overlayLeftText
            case .right? :
                overlayImageView.image = UIImage(systemName: overlayRightImageName)
                backgroundView.backgroundColor = overlayRightColor
                overlayLabel.text = overlayRightText
            default:
                overlayImageView.image = nil
                backgroundView.backgroundColor = .clear
                overlayLabel.text = ""
            }
        }
    }

}
