//
//  IAPManager.swift
//  AmcaTOEIC
//
//  Created by Anto-Yang on 3/1/25.
//

import Foundation
import StoreKit

class IAPManager {
    
    static let shared = IAPManager()
   
    private let productIdentifiers: [ProductIdentifierType] = [.Sample_ID, .AnotherProductID] // 나중에 상품이 여러 개로 확장될 수 있음
    
    enum ProductIdentifierType: String {
        case Sample_ID
        case AnotherProductID
    }
    
    private init() {}
    
    // MARK: - 상품 구매 여부 확인
    func isProductPurchased(productIdentifier: ProductIdentifierType) -> Bool {
        return IAPHelper.shared.isProductPurchased(productIdentifier: productIdentifier.rawValue)
    }
    
    // MARK: - 모든 상품 구매 여부 확인
    func areAllProductsPurchased() -> Bool {
        for productIdentifier in productIdentifiers {
            if !IAPHelper.shared.isProductPurchased(productIdentifier: productIdentifier.rawValue) {
                return false
            }
        }
        return true
    }
    
    // MARK: - 상품 구매
    func buyProduct(productIdentifier: ProductIdentifierType, completion: @escaping (Result<SKPaymentTransaction, Error>) -> Void) {
        IAPHelper.shared.buyProduct(productIdentifier: productIdentifier.rawValue) { result in
            switch result {
            case .success(let transaction):
                print("Product purchased successfully: \(transaction.payment.productIdentifier)")
                completion(.success(transaction))
            case .failure(let error):
                print("Purchase failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 상품 복원
    func restorePurchases(completion: @escaping (Result<[SKPaymentTransaction], Error>) -> Void) {
        IAPHelper.shared.restorePurchases { result in
            switch result {
            case .success(let transactions):
                print("Restored purchases: \(transactions.count)")
                completion(.success(transactions))
            case .failure(let error):
                print("Restore failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
