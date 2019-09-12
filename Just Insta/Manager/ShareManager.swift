//
//  ShareManager.swift
//  test
//
//  Created by Kostya Bershov on 5/7/19.
//  Copyright © 2019 Daoinek Studio. All rights reserved.
//

import UIKit
import MessageUI


class ShareManager: NSObject {
    
    
    var mailController =  MFMailComposeViewController()

    func sendMail(adresatMail: [String], subject: String, text: String, vc: UIViewController){
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        mailController.mailComposeDelegate = self
        mailController.setToRecipients(adresatMail)
        mailController.setSubject(subject)
        mailController.setMessageBody(text, isHTML: false)
        
        vc.present(mailController, animated: true, completion: nil)
    }
    
    var activityVC : UIActivityViewController?
    func share(objects: [AnyObject?], showInController: UIViewController) {
        
        var trueObject: [AnyObject] = []
        for o in objects {
            if let o = o {
                trueObject.append(o)
            }
        }
        
        activityVC = UIActivityViewController(activityItems: trueObject, applicationActivities: nil)
        showInController.present(activityVC!, animated: true, completion: nil)
    }
}

extension ShareManager: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
