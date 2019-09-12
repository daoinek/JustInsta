//
//  InstaController.swift
//  Just Insta
//
//  Created by Kostya Bershov on 4/8/19.
//  Copyright © 2019 Daoinek Studio. All rights reserved.
//

import UIKit
import Firebase

class InstaController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource {
    
    override func viewDidLoad() {
        stackFields.alpha = 0
        buttonStart.alpha = 0
        textView.alpha = 0
        networkStatus()
        loadOpen()
        testLoadOrder()
        spinLoadOrder()
        textView.alpha = 0
        priceCoinLabel.alpha = 0
        readFromFile()
        let thePicker1 = UIPickerView()
        let thePicker2 = UIPickerView()
        kategoryField.inputView = thePicker1
        typeField.inputView = thePicker2
        thePicker1.delegate = self
        thePicker1.dataSource = self
        thePicker2.delegate = self
        thePicker2.dataSource = self
        super.viewDidLoad()
        self.hideKeyboard()
        defCoinCount()
        textCount.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        typeField.isUserInteractionEnabled = false
        textCount.isUserInteractionEnabled = false
        textLink.isUserInteractionEnabled = false
        typeField.alpha = 0.65
        textCount.alpha = 0.65
        textLink.alpha = 0.65
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        buttonStart.backgroundColor = .black
        buttonStart.layer.cornerRadius = 5
        buttonStart.layer.borderWidth = 1
        buttonStart.layer.borderColor = UIColor.black.cgColor
            }
    
    override func viewDidAppear(_ animated: Bool) {
        self.coinButton.title = "\(NSLocalizedString("Coins:", comment: "")) \(String(format: "%.2f", coinCount ?? "нет сети"))"
        stopSpiner = false
    }
    
    
   // MARK: - Переменные
    var serviceType: String = ""
    var nakrutkaType: String = ""
    var costOrder: Float = 0
    var typeHistory: String = ""
    var stopSpiner: Bool = false

    
    // MARK: - Установка связи
    
    @IBOutlet weak var stackFields: UIStackView!
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var coinButton: UIBarButtonItem!
    @IBOutlet weak var kategoryField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var textLink: UITextField!
    @IBOutlet weak var textCount: UITextField!
    @IBOutlet weak var priceCoinLabel: UILabel!
    
     // MARK: - Функции
    
    
    
    
    func defCoinCount() {
        if Reachability.isConnectedToNetwork() == true {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if coinCount == nil {
                        self.coinButton.title = "no network".localized
                        print("нет сети")
                    } else {
                        self.coinButton.title = "\(NSLocalizedString("Coins:", comment: "")) \(String(format: "%.2f", coinCount!))"
                        timer.invalidate() }
            }
        } else {
            self.coinButton.title = "no network".localized
        }
    }
    
    func spinLoadOrder() {
        let child = SpinnerViewController()
        let bl = newLoadPriceAndId()
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if bl {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
                timer.invalidate()
                UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
                    self.stackFields.alpha = 1
                    self.buttonStart.alpha = 1
                }) { _ in print("Animation Done") }
            }
        }
        
    }
    
    func loadOpen() {
        let bbbb = Auth.auth().currentUser?.isEmailVerified
        
        
        if Auth.auth().currentUser?.isEmailVerified == true {
            print("Почтовый ящик подтвержден!")
            let userID = Auth.auth().currentUser!.uid
            let ref = Database.database().reference().child("users/\(userID)")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild("openInfo"){
                    print("Открытие уже было")
                } else {
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let fullInsta = storyBoard.instantiateViewController(withIdentifier: "testVC")
                    self.present(fullInsta, animated: true, completion: nil)
                }
            })
        } else {
            print("Почтовый ящик не подтвержден!")
            print(bbbb!)
        }
    }
    
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
    
    func roundUp(_ value: Float, toNearest: Float) {
        let resultNear = ceil(value / toNearest) * toNearest
        saveCoin(newCoin: resultNear)
    }
    
    func hideKey() {
        view.endEditing(true)
    }
    
    func coinPricing(payCoin: Float, quantity: String) {
        let qua = Float(quantity)!
        let payment1: Float = payCoin / 1000
        print("Подсчет 1: \(payment1)")
        let payment2: Float = payment1 * qua
        print("Подсчет 2: \(payment2)")
        let coinn = coinCount! - payment2
        print("Подсчет 3: \(coinn)")
        roundUp(coinn, toNearest: 0.01)
        coinButton.title = "\("Coins:".localized) \(String(format: "%.2f", coinCount!))"
    }
    
    func networkStatus() {
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
            
        } else {
            print("Internet connection FAILED")
            WarningLable(text: "Internet connection FAILED".localized)
        }
    }
    
    
    
    @objc func editingChanged(_ textField: UITextField) {
        let texts: String = textField.text!
        if texts.isEmpty {
            priceCoinLabel.alpha = 0
        } else{
            if Float(texts) != nil {
        coinPrice(payCoin: costOrder, quantity: texts)
            } else {
                priceCoinLabel.text = "Use count".localized
                priceCoinLabel.alpha = 1
            }
        }
    }
    
    func reserchCoin(payCoin: Float, quantity: String) -> Bool{
        let qua = Float(quantity)!
        let payment1: Float = payCoin / 1000
        let payment2: Float = payment1 * qua
        if coinCount! > payment2 {
            return true
        } else if coinCount! == payment2 {
            return true
        }else {
            return false
        }
    }
    
    func coinPrice(payCoin: Float, quantity: String) {
        if quantity.isEmpty == false {
            let firstCoin = Float(quantity)!
        let SecondCoin: Float = payCoin / 1000
        print("Подсчет 1: \(SecondCoin)")
        let payment2: Float = SecondCoin * firstCoin
        print("Подсчет 2: \(payment2)")
        priceCoinLabel.text = "\("Will be charged coins:".localized) \(String(format: "%.2f", payment2))"
        priceCoinLabel.alpha = 1
        }
    }
    
    // MARK: - Алерты
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
            
        }
        
        alertNetwork.addAction(alertAction)
        
        present(alertNetwork, animated: true, completion: nil)
    }
    

    // MARK: - Пикеры с услугами
    let pickerCategoryType = ["Select category".localized, "Followers".localized, "Likes".localized, "Comments".localized, "Views".localized, "Statistic".localized]
    
    var pickerViewMain = ["Выберите категорию", "Выберите категорию", "Выберите категорию", "Выберите категорию"]
    let pickerViewValues0 = ["Укажите категорию", "Укажите категорию", "Укажите категорию", "Укажите категорию"]
    let pickerViewValues1 = ["Выберите услугу", "Подписчики S", "Подписчики M ", "Подписчики L"]
    let pickerViewValues2 = ["Выберите услугу", "Лайки S", "Лайки M", "Лайки L"]
    let pickerViewValues3 = ["Выберите услугу", "Лайк на комментарий", "Комментарии S", "Комментарии M"]
    let pickerViewValues4 = ["Выберите услугу", "Просмотры видео", "Просмотры историй", "Прямые эфиры"]
    let pickerViewValues5 = ["Выберите услугу", "Показы и охват", "Сохранения", "Послещения профиля"]
    
    // MARK: - Параметры ячеек пикеров
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == kategoryField.inputView { return pickerCategoryType.count}
        else if pickerView == typeField.inputView {return pickerViewMain.count}
        else {return 0}
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == kategoryField.inputView { return pickerCategoryType[row]}
        else if pickerView == typeField.inputView { return pickerViewMain[row]}
        else { return pickerViewValues0[row]}
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == kategoryField.inputView {
            switch row {
            case 0:
                print("Укажите категорию")
                kategoryField.text = "Выберите категорию"
                textView.alpha = 0
                typeField.isUserInteractionEnabled = false
                textCount.isUserInteractionEnabled = false
                textLink.isUserInteractionEnabled = false
                typeField.text = ""
                textView.text = ""
                typeField.alpha = 0.65
                textCount.alpha = 0.65
                textLink.alpha = 0.65
                nakrutkaType = "error"
                pickerViewMain = pickerViewValues0
            case 1:
                kategoryField.text = "Заказать подписчики"
                typeHistory = "Подписчики"
                nakrutkaType = "follow"
                pickerViewMain = pickerViewValues1
                typeField.isUserInteractionEnabled = true
                typeField.alpha = 1
                typeField.text = ""
                textView.text = ""
                textCount.isUserInteractionEnabled = true
                textLink.isUserInteractionEnabled = true
                textCount.alpha = 1
                textLink.alpha = 1
                print("Подписчики")
            case 2:
                kategoryField.text = "Заказать лайки"
                typeHistory = "Лайки"
                nakrutkaType = "like"
                pickerViewMain = pickerViewValues2
                typeField.isUserInteractionEnabled = true
                typeField.alpha = 1
                typeField.text = ""
                textView.text = ""
                textCount.isUserInteractionEnabled = true
                textLink.isUserInteractionEnabled = true
                textCount.alpha = 1
                textLink.alpha = 1
                print("Лайки")
            case 3:
                kategoryField.text = "Заказать комментарии"
                typeHistory = "Комментарии"
                nakrutkaType = "comment"
                pickerViewMain = pickerViewValues3
                typeField.isUserInteractionEnabled = true
                typeField.alpha = 1
                typeField.text = ""
                textView.text = ""
                textCount.isUserInteractionEnabled = true
                textLink.isUserInteractionEnabled = true
                textCount.alpha = 1
                textLink.alpha = 1
                print("Комментарии")
            case 4:
                kategoryField.text = "Заказать просмотры"
                typeHistory = "Просмотры"
                nakrutkaType = "view"
                pickerViewMain = pickerViewValues4
                typeField.isUserInteractionEnabled = true
                typeField.alpha = 1
                typeField.text = ""
                textView.text = ""
                textCount.isUserInteractionEnabled = true
                textLink.isUserInteractionEnabled = true
                textCount.alpha = 1
                textLink.alpha = 1
                print("Просмотры")
            case 5:
                kategoryField.text = "Заказать статистика"
                typeHistory = "Статистика"
                nakrutkaType = "stat"
                pickerViewMain = pickerViewValues5
                typeField.isUserInteractionEnabled = true
                typeField.alpha = 1
                typeField.text = ""
                textView.text = ""
                textCount.isUserInteractionEnabled = true
                textLink.isUserInteractionEnabled = true
                textCount.alpha = 1
                textLink.alpha = 1
                print("Статистика")
            default:
                break
            }
        }
        else if pickerView == typeField.inputView {
            switch row {
            case 0:
                print("Укажите тип")
                    typeField.text = "Выберите услугу"
                    textView.alpha = 0
            case 1:
                switch nakrutkaType {
                case "follow":
                    typeField.text = "Подписчики S - \(orderPrices["follows"]![0]) монет за 1000"
                    serviceType = String(orderIDs["follows"]![0])
                    costOrder = Float(orderPrices["follows"]![0])!
                    textView.text = textArray[0]
                    textView.alpha = 1
                    print("follow1")
                case "like":
                    typeField.text = "Лайки S - \(orderPrices["likes"]![0]) монет за 1000"
                    serviceType = String(orderIDs["likes"]![0])
                    costOrder = Float(orderPrices["likes"]![0])!
                    textView.text = textArray[3]
                    textView.alpha = 1
                    print("like1")
                case "comment":
                    typeField.text = "Лайк на комментарий - \(orderPrices["comments"]![0]) монет за 1000"
                    serviceType = String(orderIDs["comments"]![0])
                    costOrder = Float(orderPrices["comments"]![0])!
                    textView.text = textArray[6]
                    textView.alpha = 1
                    print("comment1")
                case "view":
                    typeField.text = "Просмотры видео - \(orderPrices["views"]![0]) монет за 1000"
                    serviceType = String(orderIDs["views"]![0])
                    costOrder = Float(orderPrices["views"]![0])!
                    textView.text = textArray[9]
                    textView.alpha = 1
                    print("view1")
                case "stat":
                    typeField.text = "Показы и охват - \(orderPrices["stats"]![0]) монет за 1000"
                    serviceType = String(orderIDs["stats"]![0])
                    costOrder = Float(orderPrices["stats"]![0])!
                    textView.text = textArray[12]
                    textView.alpha = 1
                    print("stat1")
                default:
                    print("ошибка")
                }
            case 2:
                switch nakrutkaType {
                case "follow":
                    typeField.text = "Подписчики M - \(orderPrices["follows"]![1]) монет за 1000"
                    serviceType = String(orderIDs["follows"]![1])
                    costOrder = Float(orderPrices["follows"]![1])!
                    textView.text = textArray[1]
                    textView.alpha = 1
                    print("follow2")
                case "like":
                    serviceType = String(orderIDs["likes"]![1])
                    typeField.text = "Лайки M - \(orderPrices["likes"]![1]) монет за 1000"
                    costOrder = Float(orderPrices["likes"]![1])!
                    textView.text = textArray[4]
                    textView.alpha = 1
                    print("like2")
                case "comment":
                    typeField.text = "Комментарии S - \(orderPrices["comments"]![1]) монет за 1000"
                    serviceType = String(orderIDs["comments"]![1])
                    costOrder = Float(orderPrices["comments"]![1])!
                    textView.text = textArray[7]
                    textView.alpha = 1
                    print("comment2")
                case "view":
                    typeField.text = "Просмотры историй - \(orderPrices["views"]![1]) монет за 1000"
                    serviceType = String(orderIDs["views"]![1])
                    costOrder = Float(orderPrices["views"]![1])!
                    textView.text = textArray[10]
                    textView.alpha = 1
                    print("view2")
                case "stat":
                    typeField.text = "Сохранения - \(orderPrices["stats"]![1]) монет за 1000"
                    serviceType = String(orderIDs["stats"]![1])
                    costOrder = Float(orderPrices["stats"]![1])!
                    textView.text = textArray[13]
                    textView.alpha = 1
                    print("stat2")
                default:
                    print("ошибка")
                }
            case 3:
                switch nakrutkaType {
                case "follow":
                    typeField.text = "Подписчики L - \(orderPrices["follows"]![2]) монет за 1000"
                    serviceType = String(orderIDs["follows"]![2])
                    costOrder = Float(orderPrices["follows"]![2])!
                    textView.text = textArray[2]
                    textView.alpha = 1
                    print("follow3")
                case "like":
                    typeField.text = "Лайки L - \(orderPrices["likes"]![2]) монет за 1000"
                    serviceType = String(orderIDs["likes"]![2])
                    costOrder = Float(orderPrices["likes"]![2])!
                    textView.text = textArray[5]
                    textView.alpha = 1
                    print("like3")
                case "comment":
                    typeField.text = "Комментарии M - \(orderPrices["comments"]![2]) монет за 1000"
                    serviceType = String(orderIDs["comments"]![2])
                    costOrder = Float(orderPrices["comments"]![2])!
                    textView.text = textArray[8]
                    textView.alpha = 1
                    print("comment3")
                case "view":
                    typeField.text = "Прямые эфиры - \(orderPrices["views"]![2]) монет за 1000"
                    serviceType = String(orderIDs["views"]![2])
                    costOrder = Float(orderPrices["views"]![2])!
                    textView.text = textArray[11]
                    textView.alpha = 1
                    print("view3")
                case "stat":
                    typeField.text = "Послещения профиля - \(orderPrices["stats"]![2]) монет за 1000"
                    serviceType = String(orderIDs["stats"]![2])
                    costOrder = Float(orderPrices["stats"]![2])!
                    textView.text = textArray[14]
                    textView.alpha = 1
                    print("stat3")
                default:
                    print("ошибка")
                }
            default:
                break
            }
        }
    }


    // MARK: - Запуск слуги
    
    @IBAction func nakrutka(_ sender: UIButton) {
        let linkText = textLink.text!
        let countText = textCount.text!
        hideKey()
        if linkText == "" || countText == "" || serviceType == "" {
            WarningLable(text: "Fill in the fields".localized)
        } else {
            createSpinnerView()
            let x = reserchCoin(payCoin: costOrder, quantity: countText)
            if x == true {
        var request = URLRequest(url: URL(string: "https://smm.nakrutka.by/api/")!)
        request.httpMethod = "POST"
        let postString = "key=2c9df49839a189e16ae18049af6e6776&action=create&service=\(serviceType)&quantity=\(countText)&link=\(linkText)"
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
                self.stopSpiner = true
                self.OrderLable(text: "Request has been sent".localized)
                self.coinPricing(payCoin: self.costOrder, quantity: countText)
                let orderApiResult = parsedData["order"] as! String
                // newOrderApi(order: orderApiResult, type: self.typeHistory)
                print("Вот наш заказ \(orderApiResult)")
                // reloadInfoOrder(order: orderApiResult)
                testSaveOrder(order: orderApiResult, type: self.typeHistory)
                } else {
                    self.stopSpiner = true
                    self.WarningLable(text: "Could not order service".localized)

                }
            } catch let error as NSError {
                print(error)
            }
            
            
            if let statusZakaz = response as? HTTPURLResponse {
                print("результат = \(statusZakaz.statusCode)")
                
            }
        }
        
            print("Отправлены данные: service=\(serviceType)&quantity=\(countText)&link=\(linkText)")
        
        textLink.text = ""
        textCount.text = ""
        kategoryField.text = ""
        serviceType = ""
        typeField.text = ""
        textView.alpha = 0
        priceCoinLabel.alpha = 0
        priceCoinLabel.text = ""
        
        task.resume()
            } else {
                self.stopSpiner = true
                WarningLable(text: "Insufficient funds in the account".localized)

            }
        }
    }
    

    
}

extension InstaController {
    func hideKeyboard()
    {
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
