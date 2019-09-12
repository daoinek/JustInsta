//
//  PriceManager.swift
//  Just Insta
//
//  Created by Kostya Bershov on 7/21/19.
//  Copyright © 2019 Daoinek Studio. All rights reserved.
//

import UIKit
import StoreKit

let nPricesComplited = "nPricesComplited"

class PriceManager: NSObject {
    
    func getPricesFromAppStore(inAppsID: Set<String>) {
        if !SKPaymentQueue.canMakePayments() {
            print("Не можем делать покупки!")
            return
        }
        
        let request = SKProductsRequest(productIdentifiers: inAppsID)
        request.delegate = self
        
        request.start()
    }
}

extension PriceManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        for product in response.products {
            
            let nf = NumberFormatter()
            nf.numberStyle = NumberFormatter.Style.currency
            nf.locale = product.priceLocale
            let price = "\(product.price)" + nf.currencySymbol
            
            UserDefaults.standard.set(price, forKey: product.productIdentifier)
            UserDefaults.standard.synchronize()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: nPricesComplited), object: nil)
        
        print("invalid: \(response.invalidProductIdentifiers)")
    }
    
    
}
