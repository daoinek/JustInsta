//
//  WebKitController.swift
//  Just Insta
//
//  Created by Kostya Bershov on 5/12/19.
//  Copyright © 2019 Daoinek Studio. All rights reserved.
//

import UIKit
import WebKit

class WebKitController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let reqest = URLRequest(url: URL(string: openLink)!)
        self.webViewOutlet.load(reqest)
        self.webViewOutlet.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new , context: nil)

    }
    
    @IBOutlet weak var webViewOutlet: WKWebView!
    @IBOutlet weak var activityOutlet: UIActivityIndicatorView!
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "loading" {
            if webViewOutlet.isLoading {
                activityOutlet.startAnimating()
                activityOutlet.isHidden = false
            } else {
                activityOutlet.stopAnimating()
                activityOutlet.isHidden = true
            }
        }
    }

}
