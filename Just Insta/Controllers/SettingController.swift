//
//  SettingController.swift
//  Just Insta
//
//  Created by Kostya Bershov on 5/7/19.
//  Copyright © 2019 Daoinek Studio. All rights reserved.
//

import UIKit
import Firebase
import StoreKit

class SettingController: UITableViewController {
    
    // let shareManager = ShareManager()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: nPurchaseComplited), object: nil, queue: nil) { (notification) in
            print("Покупка выполнена!")
        }
        
        coin50.text = UserDefaults.standard.object(forKey: "jastInsta.50coins") as? String
        coin100.text = UserDefaults.standard.object(forKey: "jastInsta.100coins") as? String
        coin250.text = UserDefaults.standard.object(forKey: "jastInsta.250coins") as? String
        coin500.text = UserDefaults.standard.object(forKey: "jastInsta.500coins") as? String
        coin1000.text = UserDefaults.standard.object(forKey: "jastInsta.1000coins") as? String
        coin3000.text = UserDefaults.standard.object(forKey: "jastInsta.3000coins") as? String

        
    }
    
    @IBOutlet weak var coin50: UILabel!
    @IBOutlet weak var coin100: UILabel!
    @IBOutlet weak var coin250: UILabel!
    @IBOutlet weak var coin500: UILabel!
    @IBOutlet weak var coin1000: UILabel!
    @IBOutlet weak var coin3000: UILabel!
    
    func createSpinnerView() {
        spiner = false
        let child = SpinnerViewController()
        
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            print("Проверка (таймер)")
            print(count)
            if spiner == true {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
                timer.invalidate()
            }
        }
        
    }
    
    
    func networkStatus() {
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
            
        } else {
            print("Internet connection FAILED")
            WarningLable(text: "Internet connection FAILED".localized)
            spiner = true
        }
    }
    
    func WarningLable (text: String) {
        let alertNetwork = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default) { (alert) in
            
        }
        
        alertNetwork.addAction(alertAction)
        
        present(alertNetwork, animated: true, completion: nil)
    }
    
    
    private func priceStringFore(product: SKProduct) -> String {
        let numberFormater = NumberFormatter()
        numberFormater.numberStyle = .currency
        numberFormater.locale = product.priceLocale
        
        return numberFormater.string(from: product.price)!
    }
    
    var storeManager = StoreManager()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        
        if indexPath.section == 0 && indexPath.row == 0 {
            // Купить монеты 1
            storeManager.buyInApp(inAppId: "jastInsta.50coins")
            coinsID = "50"
            createSpinnerView()
            networkStatus()
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            // Купить монеты 2
            storeManager.buyInApp(inAppId: "jastInsta.100coins")
            coinsID = "100"
            createSpinnerView()
            networkStatus()

        }
        if indexPath.section == 0 && indexPath.row == 2 {
            // Купить монеты 3
            storeManager.buyInApp(inAppId: "jastInsta.250coins")
            coinsID = "250"
            createSpinnerView()
            networkStatus()

        }
        if indexPath.section == 0 && indexPath.row == 3 {
            // Купить монеты 4
            storeManager.buyInApp(inAppId: "jastInsta.500coins")
            coinsID = "500"
            createSpinnerView()
            networkStatus()
        }
        if indexPath.section == 0 && indexPath.row == 4 {
            // Купить монеты 5
            storeManager.buyInApp(inAppId: "jastInsta.1000coins")
            coinsID = "1000"
            createSpinnerView()
            networkStatus()

        }
        if indexPath.section == 0 && indexPath.row == 5 {
            // Купить монеты 6
            storeManager.buyInApp(inAppId: "jastInsta.3000coins")
            coinsID = "3000"
            createSpinnerView()
            networkStatus()
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            // Поделиться приложением
            let shareManager = ShareManager()
            
            let name = "Just Insta - раскрути свой аккаунт"
            let link = NSURL(string: "https://geekon.media/")
            let image = UIImage(named: "share.png")
            
            shareManager.share(objects: [image, link, name as AnyObject], showInController: self)
        }

        if indexPath.section == 2 && indexPath.row == 0 {
            // Написать мне
            let shareManager = ShareManager()

            shareManager.sendMail(adresatMail: ["justinsta.help@gmail.com"], subject: "Обратная связь Just Insta", text: "", vc: self)
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            // Оценить приложение
            UIApplication.shared.open(NSURL(string: "itms-apps://itunes.apple.com/app/1473685720")! as URL)
        }
        if indexPath.section == 3 && indexPath.row == 0 {
            let alertController = UIAlertController(title: "Do you really want to logout?".localized, message: nil, preferredStyle: .alert)
            
            let alertAction1 = UIAlertAction(title: "No".localized, style: .cancel) { (alert) in }
            let alertAction2 = UIAlertAction(title: "Yes".localized, style: .default) { (alert) in
                do {
                    try Auth.auth().signOut()
                        //historyArray.removeAll()
                        testOrderInfo.removeAll()
                        coinCount = 0.0
                    
                } catch {
                    print(error.localizedDescription)
                }
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                //Sign out action
            }
            
            alertController.addAction(alertAction1)
            alertController.addAction(alertAction2)
            
            present(alertController, animated: true, completion: nil)
        }

    }
    
}

