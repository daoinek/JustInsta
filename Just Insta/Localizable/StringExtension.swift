//
//  StringExtension.swift
//  Just Insta
//
//  Created by Kostya Bershov on 6/13/19.
//  Copyright © 2019 Daoinek Studio. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        if let _ = UserDefaults.standard.string(forKey: "newLang") {} else {
            // we set a default, just in case
            var localLeng: String
            let locale = NSLocale.preferredLanguages.first!
            if locale.hasPrefix("ru") {
                 localLeng = "ru"
            } else {
                localLeng = "en"
            }
            
            UserDefaults.standard.set(localLeng, forKey: "newLang")
            UserDefaults.standard.synchronize()
        }
        
        let lang = UserDefaults.standard.string(forKey: "newLang")
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }}
