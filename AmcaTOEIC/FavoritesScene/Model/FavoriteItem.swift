//
//  FavoriteItem.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 6/26/24.
//

import Foundation
import RealmSwift

class FavoriteItem {
    let cardItem: CardItem
    let favoriteData: FavoriteData
    private(set) var isFavorite: Bool
    
    init(cardItem: CardItem, favoriteData: FavoriteData, isFavorite: Bool) {
        self.cardItem = cardItem
        self.favoriteData = favoriteData
        self.isFavorite = isFavorite
    }
}

extension FavoriteItem{
    
    ///cardItem의 favorite 정보를 DB에 업데이트한다. 등록 해제된 favoriteData는 삭제하지 않으며, fetch시에 삭제한다.
    func updateFavorite(_ isFavorite: Bool) {
        self.isFavorite = isFavorite
        let item = cardItem
        do {
            let realm = try Realm()
            try realm.write {
                // FavoriteData 생성/삭제, CardItem 업데이트
                
                if isFavorite {
                    //새 FavoriteData 생성
                    let favoriteData = FavoriteData()
                    realm.add(favoriteData)
                    
                    //CardItem에 등록
                    item.isFavorite = true
                    item.favoriteData = favoriteData
                    realm.add(item, update: .modified)
                } else {
                    
                    //CardItem에서 삭제
//                    let favoriteData = item.favoriteData
                    item.isFavorite = false
                    item.favoriteData = nil
                    realm.add(item, update: .modified)
                    
                    
                    //FavoriteData는 삭제하지 않는다.
//                    guard let favoriteData else {
//                        shLog("Favorite 삭제 실패: \(item.frontWord)의 favoriteData가 없음")
//                        return
//                    }
//
//                    realm.delete(favoriteData)
                    
                }
                
                shLog("Favorite 등록/삭제 완료: \(item.frontWord) to \(isFavorite)")
                
            }
        } catch(let error) {
            shLog(error.localizedDescription)
        }
    }
}
