//
//  FavoritesVM.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 6/26/24.
//

import Foundation
import RealmSwift
import Combine

class FavoritesVM {
    
    ///단어 아이템 리스트
    let favoriteItems = CurrentValueSubject<[FavoriteItem],Never>([])
    
    ///총 카드수
    var totalCardCount: Int {
        return favoriteItems.value.filter({$0.isFavorite}).count
    }
    
    ///암기 잔여 카드수
    var remainCardCount: Int {
        return favoriteItems.value.filter{$0.isFavorite}.filter{!$0.favoriteData.hasMemorized}.count
    }
    
  
    ///DB의 FavoriteData를 불러와서 [FavoriteItem]를 만든다.
    func fetchFavoriteItem() {
        do {
            let realm = try Realm()
            let results = realm.objects(FavoriteData.self)
            let items =  Array(results).compactMap({ data in
                
                if let parentCardItem = data.parentCardItem.first {
                    return FavoriteItem(cardItem: parentCardItem, favoriteData: data, isFavorite: true)
                    
                } else {
                    shLog("parentCardItem가 nil인 FavoriteItem 발견")
                    
                    do {
                        try realm.write {
                            realm.delete(data)
                        }
                        shLog("parentCardItem가 nil인 FavoriteItem 삭제 성공")
                    } catch {
                        shLog("parentCardItem가 nil인 FavoriteItem 삭제 실패")
                        shLog("Error retrieving data from Realm: \(error)")
                    }
              
                    return nil
                }
                
            })
            
            favoriteItems.send(items)
            shLog("단어장 데이터 불러오기 완료")
            
        } catch {
            shLog("단어장 데이터 불러오기 실패")
            shLog("Error retrieving data from Realm: \(error)")
            favoriteItems.send([])
        }
        
    }
    
    ///favorite를 선택, 해제 한다.
    func markFavorite(at index: Int, _ isFavorite: Bool) {
        guard index < favoriteItems.value.count else { shLog("오류: 오버레인지"); return  }
        let favoriteItem = favoriteItems.value[index]
        favoriteItem.updateFavorite(isFavorite)
    }

}
