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
   
    let productIdentifier = "Sample_ID"

    private init() {}
    
    ///몇번째 챕터까지 무료인지
    var freeChapterNumber: Int = 3
    
    //MARK: - 상품 가격
    func getProductPrice(completion: @escaping (SKProduct?)-> Void ){
        IAPHelper.shared.fetchProducts(productIdentifiers: [productIdentifier]) { result in
            switch result {
            case .success(let products):
                guard let product = products.first else {
                    shLog("Error: productNotFound")
                    completion(nil)
                    return
                }
            
                completion(product)
                
            case .failure(let error):
                shLog("Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    // MARK: - 상품 구매 여부 확인
    func isProductPurchased() -> Bool {
        return IAPHelper.shared.isProductPurchased(productIdentifier: productIdentifier)
    }
    
    // MARK: - 상품 구매
    func buyProduct(completion: @escaping (Result<SKPaymentTransaction, Error>) -> Void) {
        IAPHelper.shared.buyProduct(productIdentifier: productIdentifier) { result in
            switch result {
            case .success(let transaction):
                shLog("구매 성공: \(transaction.payment.productIdentifier)")
                completion(.success(transaction))
            case .failure(let error):
                shLog("구매 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 상품 복원
    func restorePurchases(completion: @escaping (Result<[SKPaymentTransaction], Error>) -> Void) {
        IAPHelper.shared.restorePurchases { result in
            switch result {
            case .success(let transactions):
                print("구매 복원 성공: \(transactions.count)")
                completion(.success(transactions))
            case .failure(let error):
                print("구매 복원 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
