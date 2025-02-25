//
//  EmailHelper.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 5/4/24.
//

import Foundation
import UIKit
import MessageUI

class EmailHelper: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailHelper()
    private override init() {
        //
    }
    
    func sendEmail(subject:String, body:String, to:String){
        if MFMailComposeViewController.canSendMail() {
            let picker = MFMailComposeViewController()
            
            picker.setSubject(subject)
            picker.setMessageBody(body, isHTML: false)
            picker.setToRecipients([to])
            picker.mailComposeDelegate = self
            
            UIViewController.getTopViewController()?.present(picker, animated: true, completion: nil)
        } else {
            shLog("No mail account found")
            guard let baseVC = UIViewController.getTopViewController() else { return }
            
            AlertHelper.alertInform(baseVC: baseVC, title: "이메일 계정이 없습니다.", message: "iPhone에 설정된 이메일 계정이 없어서 이메일 전송이 불가능합니다.\n이메일 계정을 설정해주세요.", confirmCompletion: {})
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        UIViewController.getTopViewController()?.dismiss(animated: true, completion: nil)
    }
    
    
}
