//
//  NewPasswordViewController.swift
//  Just Insta
//
//  Created by Kostya Bershov on 5/6/19.
//  Copyright © 2019 Daoinek Studio. All rights reserved.
//

import UIKit
import FirebaseAuth

class NewPasswordController: UIViewController {
    
    @IBOutlet weak var emailResetField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        stopSpiner = false
    }
    
    
    var stopSpiner: Bool = false
    
    func createSpinnerView() {
        let child = SpinnerViewController()
        
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.stopSpiner == true {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
                timer.invalidate()
            }
        }
        
    }
    
    func hideKey() {
        view.endEditing(true)
    }
    
    func WarningLable(text: String) {
        let alertNetwork = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default) { (alert) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertNetwork.addAction(alertAction)
        
        present(alertNetwork, animated: true, completion: nil)
    }
    

    @IBAction func resetPasswordButton(_ sender: UIButton) {
        let email = emailResetField.text!
        hideKey()
        if (!email.isEmpty) {
            createSpinnerView()
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if error == nil {
                    self.stopSpiner = true
                    self.WarningLable(text: "Request has been sent".localized)
                }
            }
        }
        emailResetField.text = ""
    }
    
    @IBAction func closeResetView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
