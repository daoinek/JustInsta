//
//  StoreManager.swift
//  Just Insta
//
//  Created by Kostya Bershov on 7/21/19.
//  Copyright © 2019 Daoinek Studio. All rights reserved.
//

import UIKit
import StoreKit

let nPurchaseComplited = "nPurchaseComplited"


class StoreManager: NSObject {
    
    
    
    func buyInApp(inAppId: String) {
        if !SKPaymentQueue.canMakePayments() {
            print("Не можем делать покупки!")
            return
        }
        
        let productRequest = SKProductsRequest(productIdentifiers: [inAppId])
        productRequest.delegate = self
        productRequest.start()
    }
    

    
}


extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if response.products.count > 0 {
            let product = response.products[0]
            let payment = SKPayment(product: product)
            
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
        
        print("invalid: \(response.invalidProductIdentifiers)")
    }
    
    
}

extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            if transaction.transactionState == SKPaymentTransactionState.purchasing {
                print("SKPaymentTransactionState.purchasing")
            }
            if transaction.transactionState == SKPaymentTransactionState.purchased {
                print("SKPaymentTransactionState.purchased")
                queue.finishTransaction(transaction)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: nPurchaseComplited), object: nil)
                buyCoin()
                spiner = true
            }
            if transaction.transactionState == SKPaymentTransactionState.failed {
                print("SKPaymentTransactionState.failed")
                queue.finishTransaction(transaction)
                spiner = true
                print("Ошибка транзакции")
            }
            if transaction.transactionState == SKPaymentTransactionState.restored {
                print("SKPaymentTransactionState.restored")
                queue.finishTransaction(transaction)
            }
            if transaction.transactionState == SKPaymentTransactionState.deferred {
                print("SKPaymentTransactionState.deferred")
            }
            
        }
    }
    
    
}
