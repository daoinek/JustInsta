//
//  KOLocalizedClass.swift
//  test
//
//  Created by Kostya Bershov on 5/29/19.
//  Copyright © 2019 Daoinek Studio. All rights reserved.
//

import UIKit

class KOLocalizedClass: NSObject {
    static let instanc = KOLocalizedClass()
    
    private let localeArray:Array = ["ru","en"]
    private let keyLocale: String = "kLocale"
    private let endNameFile: String = "Localizable"
    
    private var localeDictionary : NSDictionary!
    private let typeLocalizable  : String = "plist"
    private var nameFile         : String!
    
    override init() {
        super.init()
        checkFirstInit()
    }
    //MARK: Public Methods
    public func changeLocalized(key:String){
        UserDefaults.standard.set("\(key)_\(endNameFile)", forKey: keyLocale)
        nameFile = "\(key)_\(endNameFile)"
        updateDictionary()
    }
    
    //MARK: Internal Methods
    internal func valueWith(key:String) -> String {
        var value:String
        value = localeDictionary.object(forKey: key) as? String ?? key
        return value
    }
    
    //MARK: Privat Methods
    private func checkFirstInit(){
        if UserDefaults.standard.object(forKey: keyLocale) == nil{
            var langValue:String {
                var systemLocale : String = NSLocale.preferredLanguages[0]
                
                if systemLocale.count > 2 {
                    let index = systemLocale.range(of: "-")?.lowerBound
                    systemLocale = systemLocale.substring(to: index!)
                }
                
                for localeString in localeArray{
                    if localeString == systemLocale{
                        systemLocale = localeString
                    }
                }
                return systemLocale == "" ? systemLocale: "en"
            }
            UserDefaults.standard.set("\(langValue)_\(endNameFile)", forKey: keyLocale)
            nameFile = "\(langValue)_\(endNameFile)"
        }else{
            nameFile = UserDefaults.standard.object(forKey: keyLocale) as! String
        }
        updateDictionary()
    }
    //Update Dictionary
    private func updateDictionary(){
        if let path =  Bundle.main.path(forResource: nameFile, ofType: typeLocalizable) {
            localeDictionary = NSDictionary(contentsOfFile: path)!
        }
    }
}
