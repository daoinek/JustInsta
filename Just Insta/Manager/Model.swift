//
//  ApiResult.swift
//  test
//
//  Created by Kostya Bershov on 5/8/19.
//  Copyright © 2019 Daoinek Studio. All rights reserved.
//

import Foundation
import Firebase

var coinCount: Float?
var count = 0
var spiner = false

var openLink: String = ""
var textArray = [String]()
var allTextArray = [String]()

var orderIDs: [String: [String]] = [:]
var orderPrices: [String: [String]] = [:]
var testOrderInfo: [[String:String]] = []
var coinsID: String = ""


// MARK: - Новые функции


func newLoadPriceAndId() -> Bool {

    let ref = Database.database().reference()
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.hasChild("orderIDs"){
            ref.child("orderIDs").observeSingleEvent(of: .value, with: { (Snapshot) in
                if let diction = Snapshot.value as? NSDictionary {
                    orderIDs["likes"] = diction["likes"] as? [String]
                    orderIDs["follows"] = diction["follows"] as? [String]
                    orderIDs["views"] = diction["views"] as? [String]
                    orderIDs["comments"] = diction["comment"] as? [String]
                    orderIDs["stats"] = diction["stat"] as? [String]
                    print("orderIDs: \(orderIDs)")
                }
            })
        }
    })
    
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.hasChild("orderPrices"){
            ref.child("orderPrices").observeSingleEvent(of: .value, with: { (Snapshot) in
                if let diction = Snapshot.value as? NSDictionary {
                    orderPrices["likes"] = diction["likes"] as? [String]
                    orderPrices["follows"] = diction["follows"] as? [String]
                    orderPrices["views"] = diction["views"] as? [String]
                    orderPrices["comments"] = diction["comments"] as? [String]
                    orderPrices["stats"] = diction["stats"] as? [String]
                    print("orderPrices: \(orderPrices)")
                    print("Тестирую фигню: \(orderPrices["likes"]![0])")

                }
            })
        }
    })
    
    return true
}


func testLoadOrder() {
    testOrderInfo.removeAll()
    let userID = Auth.auth().currentUser!.uid
    let ref = Database.database().reference().child("users/\(userID)")
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.hasChild("orderDetal"){
            ref.child("orderDetal").observeSingleEvent(of: .value, with: { (Snapshot) in
                if let arrays = Snapshot.value as? NSArray {
                    for i in arrays as! [[String: String]] {
                        let value = i
                        testOrderInfo.append(value)
                        print("Вот что в итоге: \(testOrderInfo)")
                        
                    }
                }
            })
        }
    })
}


func saveOrderDetal() {
    let userID = Auth.auth().currentUser!.uid
    let ref = Database.database().reference().child("users/\(userID)")
    ref.child("orderDetal").setValue(testOrderInfo)
    print("Сохранили детали заказов после обновления статуса")
}



func testSaveOrder(order: String, type: String) {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    let result = formatter.string(from: date)
    
    var request = URLRequest(url: URL(string: "https://smm.nakrutka.by/api/")!)
    request.httpMethod = "POST"
    let postString = "key=2c9df49839a189e16ae18049af6e6776&action=status&order=\(order)"
    request.httpBody = postString.data(using: .utf8)
    
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {                                                 // check for fundamental networking error
            print("error=\(String(describing: error))")
            return
        }
        
        do {
            let parsedData = try JSONSerialization.jsonObject(with: data) as! [String:Any]
            let countData = parsedData["quantity"] as! String
            print("Количество: \(countData)")
            let linkData = parsedData["link"] as! String
            print("Ccылка: \(linkData)")
            let statusData = parsedData["status"] as! String
            print("Статус: \(statusData)")
            // historyArray.append(order)
            testOrderInfo.append(["orderID": order, "count": countData, "link": linkData, "status": statusData, "type": type, "date": result])
            
            let userID = Auth.auth().currentUser!.uid
            let ref = Database.database().reference().child("users/\(userID)")
            ref.child("orderDetal").setValue(testOrderInfo)
            // ref.child("orderID").setValue(historyArray)
            
            
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    task.resume()
}

// MARK: - Остальное

func KOLocalized(key:String)->String{
    return KOLocalizedClass.instanc.valueWith(key: key)
}


func saveOpen() {
    let userID = Auth.auth().currentUser!.uid
    let ref = Database.database().reference().child("users/\(userID)")
    ref.child("openInfo").setValue("Open")
}




func saveCoin(newCoin: Float) {
    coinCount = newCoin
    let userID = Auth.auth().currentUser!.uid
    let ref = Database.database().reference().child("users/\(userID)")
    ref.child("coinInfo").setValue(coinCount)
    print("Сохранили монеты: \(String(describing: coinCount))")
}


func loadCoin() {
    print("Пытаемся загрузить монеты")
    let userID = Auth.auth().currentUser!.uid
    let ref = Database.database().reference().child("users/\(userID)")
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.hasChild("coinInfo"){
            ref.child("coinInfo").observeSingleEvent(of: .value, with: { (Snapshot) in
        if let value = Snapshot.value as? Float {
                            coinCount = value
            print("У нас \(String(describing: coinCount)) монет")
        } else if let value = Snapshot.value as? Int {
            coinCount = Float(value)
            print("У нас \(String(describing: coinCount)) монет")
                } else if let value = Snapshot.value as? Double {
                    coinCount = Float(value)
            print("У нас \(String(describing: coinCount)) монет")
                }
                 })
        } else {
            print("Нет монет")
            coinCount = 0.0
        }
                })

            }

func readFromFile () {
    if let path = Bundle.main.path(forResource: "infoAboutOrder", ofType: "txt") {
        if let text = try? String(contentsOfFile: path) {
            textArray = text.components(separatedBy: "///")
        }

    }
}

func readFromAllFile () {
    if let path = Bundle.main.path(forResource: "AllOrderInfo", ofType: "txt") {
        if let text = try? String(contentsOfFile: path) {
            allTextArray = text.components(separatedBy: "///")
        }
        
    }
}

func saveLang(str: String) {
    let defaults = UserDefaults.standard
    defaults.set(str, forKey: "newLang")
}

func buyCoin() {
    
    if coinsID == "50" {
        coinCount = coinCount! + 50.0
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference().child("users/\(userID)")
        ref.child("coinInfo").setValue(coinCount)
        print("Сохранили монеты: \(String(describing: coinCount))")
        return
    }
    
    if coinsID == "100" {
        coinCount = coinCount! + 100.0
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference().child("users/\(userID)")
        ref.child("coinInfo").setValue(coinCount)
        print("Сохранили монеты: \(String(describing: coinCount))")
        return
    }
    
    if coinsID == "250" {
        coinCount = coinCount! + 250.0
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference().child("users/\(userID)")
        ref.child("coinInfo").setValue(coinCount)
        print("Сохранили монеты: \(String(describing: coinCount))")
        return
    }
    
    if coinsID == "500" {
        coinCount = coinCount! + 500.0
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference().child("users/\(userID)")
        ref.child("coinInfo").setValue(coinCount)
        print("Сохранили монеты: \(String(describing: coinCount))")
        return
    }
    
    if coinsID == "1000" {
        coinCount = coinCount! + 1000.0
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference().child("users/\(userID)")
        ref.child("coinInfo").setValue(coinCount)
        print("Сохранили монеты: \(String(describing: coinCount))")
        return
    }
    
    if coinsID == "3000" {
        coinCount = coinCount! + 3000.0
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference().child("users/\(userID)")
        ref.child("coinInfo").setValue(coinCount)
        print("Сохранили монеты: \(String(describing: coinCount))")
        return
    }
    


}


