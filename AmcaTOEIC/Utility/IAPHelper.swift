//
//  IAPHelper.swift
//  AmcaTOEIC
//
//  Created by Anto-Yang on 3/1/25.
//

import Foundation
import StoreKit

class IAPHelper: NSObject {
    
    static let shared = IAPHelper()
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    // MARK: - 상품 구매 여부 확인
    func isProductPurchased(productIdentifier: String) -> Bool {
        return UserDefaults.standard.bool(forKey: productIdentifier)
    }
    
    // MARK: - 상품 구매
    func buyProduct(productIdentifier: String, completion: @escaping (Result<SKPaymentTransaction, Error>) -> Void) {
        guard !isProductPurchased(productIdentifier: productIdentifier) else {
            completion(.failure(IAPError.alreadyPurchased))
            return
        }
        
        guard SKPaymentQueue.canMakePayments() else {
            completion(.failure(IAPError.paymentDisabled))
            return
        }
        
        IAPHelper.shared.fetchProducts(productIdentifiers: [productIdentifier]) { result in
            switch result {
            case .success(let products):
                guard let product = products.first else {
                    completion(.failure(IAPError.productNotFound))
                    return
                }
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
                self.purchaseCompletionHandler = completion
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 상품 복원
    func restorePurchases(completion: @escaping (Result<[SKPaymentTransaction], Error>) -> Void) {
        SKPaymentQueue.default().restoreCompletedTransactions()
        self.restoreCompletionHandler = completion
    }
    
    // MARK: - 상품 목록 가져오기
    func fetchProducts(productIdentifiers: Set<String>, completion: @escaping (Result<[SKProduct], Error>) -> Void) {
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
        self.completionHandler = completion
    }
    
    // MARK: - 구매 성공 처리
    private func finishTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    // MARK: - Private
    private var purchaseCompletionHandler: ((Result<SKPaymentTransaction, Error>) -> Void)?
    private var restoreCompletionHandler: ((Result<[SKPaymentTransaction], Error>) -> Void)?
    private var completionHandler: ((Result<[SKProduct], Error>) -> Void)?
    
    private func setProductPurchased(productIdentifier: String) {
        UserDefaults.standard.set(true, forKey: productIdentifier)
    }
    
    private func resetProductPurchased(productIdentifier: String) {
        UserDefaults.standard.set(false, forKey: productIdentifier)
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPHelper: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let handler = completionHandler {
            if response.products.isEmpty {
                handler(.failure(IAPError.productNotFound))
            } else {
                handler(.success(response.products))
            }
        }
        self.completionHandler = nil
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if let handler = completionHandler {
            handler(.failure(error))
        }
        self.completionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver
extension IAPHelper: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchase(transaction)
            case .failed:
                handleFailure(transaction)
            case .restored:
                handleRestored(transaction)
            case .deferred:
                handleDeferred(transaction)
            @unknown default:
                print("Unknown transaction state.")
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if let handler = restoreCompletionHandler {
            handler(.success(queue.transactions.filter { $0.transactionState == .restored }))
        }
        self.restoreCompletionHandler = nil
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let handler = restoreCompletionHandler {
            handler(.failure(error))
        }
        self.restoreCompletionHandler = nil
    }
    
    // MARK: - Handling Transaction States
    private func handlePurchase(_ transaction: SKPaymentTransaction) {
        print("Purchase successful: \(transaction.payment.productIdentifier)")
        finishTransaction(transaction)
        setProductPurchased(productIdentifier: transaction.payment.productIdentifier)
        purchaseCompletionHandler?(.success(transaction))
        purchaseCompletionHandler = nil
    }
    
    private func handleFailure(_ transaction: SKPaymentTransaction) {
        print("Purchase failed: \(transaction.error?.localizedDescription ?? "Unknown Error")")
        finishTransaction(transaction)
        purchaseCompletionHandler?(.failure(transaction.error ?? IAPError.purchaseFailed))
        purchaseCompletionHandler = nil
    }
    
    private func handleRestored(_ transaction: SKPaymentTransaction) {
        print("Restored purchase: \(transaction.payment.productIdentifier)")
        finishTransaction(transaction)
        setProductPurchased(productIdentifier: transaction.payment.productIdentifier)
    }
    
    private func handleDeferred(_ transaction: SKPaymentTransaction) {
        print("Purchase deferred: \(transaction.payment.productIdentifier)")
    }
}

// MARK: - Error Handling
enum IAPError: Error {
    case paymentDisabled
    case productNotFound
    case purchaseFailed
    case alreadyPurchased
    case restoreFailed
}
