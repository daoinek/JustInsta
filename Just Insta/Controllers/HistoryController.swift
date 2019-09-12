//
//  HistoryController.swift
//  Just Insta
//
//  Created by Kostya Bershov on 5/8/19.
//  Copyright © 2019 Daoinek Studio. All rights reserved.
//

import UIKit

class HistoryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        tableViewTable.tableFooterView = UIView()
        networkStatus()
        super.viewDidLoad()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        self.tableViewTable.reloadData()
    }
    
    func networkStatus() {
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
            
        } else {
            print("Internet connection FAILED")
            WarningLable(text: "Проблемы с интернет-подключением")
        }
    }
 
    
    func createSpinnerView() {
        let child = SpinnerViewController()
        
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            print("Проверка (таймер)")
            print(count)
            if count == testOrderInfo.count {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
                self.tableViewTable.reloadData()
                self.WarningLable(text: "Updated".localized)
                saveOrderDetal()
                timer.invalidate()
            }
        }

    }
 

    
    
    var testArray: [String] = [" "," "," "]
    let segueIdentifier = "openWebLink"
    
    func WarningLable (text: String) {
        let alertNetwork = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default) { (alert) in
            
        }
        
        alertNetwork.addAction(alertAction)
        
        present(alertNetwork, animated: true, completion: nil)
    }
    

    
    @IBOutlet var tableViewTable: UITableView!
    @IBAction func reloadHistoryTable(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Confirm action".localized, message: nil, preferredStyle: .actionSheet)
        
        let alertAction1 = UIAlertAction(title: "No".localized, style: .cancel) { (alert) in }
        let alertAction2 = UIAlertAction(title: "Yes".localized, style: .default) { (alert) in
            self.createSpinnerView()
            count = 0
            if testOrderInfo.isEmpty == false {
                for (ins, _) in testOrderInfo.enumerated() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        var request = URLRequest(url: URL(string: "https://smm.nakrutka.by/api/")!)
                        request.httpMethod = "POST"
                        let postString = "key=2c9df49839a189e16ae18049af6e6776&action=status&order=\( testOrderInfo[ins]["orderID"]!)"
                        request.httpBody = postString.data(using: .utf8)
                        
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                                print("error=\(String(describing: error))")
                                return
                            }
                            do {
                                let parsedData = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                                let statusData = parsedData["status"] as! String
                                testOrderInfo[ins]["status"] = statusData
                                count = count + 1
                                // statusDataHistory.append(statusData)
                                print("Статус: \(statusData)")
                                
                            } catch let error as NSError {
                                print(error)
                            }
                            
                        }
                        
                        task.resume()
                    }
                }
            } else {
                self.WarningLable(text: "No order".localized)
            }
        }
        
        alertController.addAction(alertAction1)
        alertController.addAction(alertAction2)
        
        present(alertController, animated: true, completion: nil)
        
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return testOrderInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        if testOrderInfo.isEmpty == false {
            cell.statusCell.text = testOrderInfo[indexPath.row]["status"]
            cell.statusCell.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            cell.statusCell.isHidden = false
            if testOrderInfo[indexPath.row]["status"] == "Pending" {
                cell.statusCell.textColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
                cell.statusCell.isHidden = false

            }
            
            cell.countCell.text = "Qt: " + testOrderInfo[indexPath.row]["count"]!
            cell.countCell.isHidden = false
            if testOrderInfo[indexPath.row]["type"] == "Лайки" {
                cell.typeCell.text = "Like"
                cell.typeCell.isHidden = false
            } else if testOrderInfo[indexPath.row]["type"] == "Подписчики" {
                cell.typeCell.text = "Follow"
                cell.typeCell.isHidden = false
            } else if testOrderInfo[indexPath.row]["type"] == "Комментарии" {
                cell.typeCell.text = "Comment"
                cell.typeCell.isHidden = false
            } else if testOrderInfo[indexPath.row]["type"] == "Просмотры" {
                cell.typeCell.text = "View"
                cell.typeCell.isHidden = false
            } else {
                cell.typeCell.isHidden = true
                cell.typeCell.text = ""
            }
            cell.dateCell.text = testOrderInfo[indexPath.row]["date"]
            cell.dateCell.isHidden = false
            
            if testOrderInfo[indexPath.row]["type"] == "Лайки" {
                cell.imgCell.image = UIImage(named: "like.png")
                cell.imgCell.isHidden = false
            } else if testOrderInfo[indexPath.row]["type"] == "Подписчики" {
                cell.imgCell.image = UIImage(named: "follow.png")
                cell.imgCell.isHidden = false
            } else if testOrderInfo[indexPath.row]["type"] == "Комментарии" {
                cell.imgCell.image = UIImage(named: "comment.png")
                cell.imgCell.isHidden = false
            } else {
                cell.imgCell.image = UIImage(named: "view.png")
                cell.imgCell.isHidden = false
            }

        } else {
            cell.statusCell.isHidden = true
            cell.statusCell.text = ""
            cell.imgCell.isHidden = true
            cell.dateCell.isHidden = true
            cell.dateCell.text = ""
            cell.countCell.isHidden = true
            cell.countCell.text = ""
        }

        return (cell)
        }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openLink = testOrderInfo[indexPath.row]["link"]!
        self.performSegue(withIdentifier: (self.segueIdentifier), sender: nil)
        
    }

    
}

