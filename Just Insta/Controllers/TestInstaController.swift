//
//  TestInstaController.swift
//  Just Insta
//
//  Created by Kostya Bershov on 5/28/19.
//  Copyright © 2019 Daoinek Studio. All rights reserved.
//

import UIKit
import Firebase

class TestInstaController: UIViewController {
    
    let segue = "testSegue"
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        hideKeyboard()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func hideKey() {
        view.endEditing(true)
    }
    
    @IBOutlet weak var linkField: UITextField!
    
    func presentInsta() {
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let fullInsta = storyBoard.instantiateViewController(withIdentifier: "fullVC")
        self.present(fullInsta, animated: true, completion: nil)
    }
        
    func WarningLable (text: String) {
        let alertNetwork = UIAlertController(title: "Error".localized, message: text, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default) { (alert) in
            
        }
        
        alertNetwork.addAction(alertAction)
        
        present(alertNetwork, animated: true, completion: nil)
    }
    
    func OrderLable(text: String) {
        let alertNetwork = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default) { (alert) in
            saveOpen()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.presentInsta()
                
            }
            
        }
        
        alertNetwork.addAction(alertAction)
        
        present(alertNetwork, animated: true, completion: nil)
    }

    
    @IBAction func skipButton(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Confirm action".localized, message: "Вы больше не сможете вернуться на этот экран", preferredStyle: .actionSheet)
                
        let alertAction1 = UIAlertAction(title: "Cancel".localized, style: .cancel) { (alert) in }
        let alertAction2 = UIAlertAction(title: "Yes".localized, style: .default) { (alert) in
                self.dismiss(animated: true, completion: nil)
                saveOpen()

        }
        
        alertController.addAction(alertAction1)
        alertController.addAction(alertAction2)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func startTest(_ sender: UIButton) {
        let link = linkField.text!
        hideKey()
        if link == "" {
            WarningLable(text: "Fill in the fields".localized)
        } else {
            let child = SpinnerViewController()
            
            // add the spinner view controller
            self.addChild(child)
            child.view.frame = self.view.frame
            self.view.addSubview(child.view)
            child.didMove(toParent: self)

                var request = URLRequest(url: URL(string: "https://smm.nakrutka.by/api/")!)
                request.httpMethod = "POST"
                let postString = "key=d51714c11f0e3c344e7dfb278bdc54df&action=create&service=3&quantity=10&link=\(link)"
                request.httpBody = postString.data(using: .utf8)
                
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {                                                 // check for fundamental networking error
                        print("error=\(String(describing: error))")
                        return
                    }
                    
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(String(describing: response))")
                    }
                    
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(responseString!)")
                    
                    
                    
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                        let proverkaOrder = parsedData["order"]
                        if proverkaOrder != nil {
                            self.OrderLable(text: "testRequest".localized)
                            child.willMove(toParent: nil)
                            child.view.removeFromSuperview()
                            child.removeFromParent()
                        } else {
                            self.WarningLable(text: "Could not order service".localized)
                            child.willMove(toParent: nil)
                            child.view.removeFromSuperview()
                            child.removeFromParent()
                            
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                    
                    
                    if let statusZakaz = response as? HTTPURLResponse {
                        print("результат = \(statusZakaz.statusCode)")
                        
                    }
                }
                task.resume()
            }
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

extension TestInstaController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(InstaController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
