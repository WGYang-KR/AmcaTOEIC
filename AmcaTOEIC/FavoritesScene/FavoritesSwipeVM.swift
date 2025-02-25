//
//  FavoritesSwipeVM.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 7/5/24.
//

import Foundation
import Combine
import RealmSwift

class FavoritesSwipeVM {

    ///단어장 전체 단어 리스트
    let favoriteItems = CurrentValueSubject<[FavoriteItem],Never>([])
    
    ///현재 학습중인 카드리스트
    let cardList = CurrentValueSubject<[FavoriteItem],Never>([])
    ///학습중인 전체 카드 개수
    let totalCardCount = CurrentValueSubject<Int,Never>(0)
    ///미학습 카드 개수
    let remainCardCount = CurrentValueSubject<Int,Never>(0)
    ///암기 카드 카운트
    let yesCardCount = CurrentValueSubject<Int,Never>(0)
    ///미암기 카드 카운트
    let noCardCount = CurrentValueSubject<Int,Never>(0)
    

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
    
    ///미학습 또는 미암기 카드만 추출하여 카드리스트를 준비한다. shuffle 이 true이면 카드를 랜덤하게 섞는다
    func prepareCardList(shuffle: Bool) {
        let fetchedCardList = favoriteItems.value.filter{ $0.isFavorite && ( !$0.favoriteData.hasMemorized || !$0.favoriteData.hasShown )}
        cardList.send(shuffle ? fetchedCardList.shuffled() : fetchedCardList )
        totalCardCount.send(cardList.value.count)
        remainCardCount.send(cardList.value.count)
        yesCardCount.send(0)
        noCardCount.send(0)
    }
    
    ///모든 카드의 학습상태  정보를 삭제한다.
    func deleteStudyStatus() {
        do {
            let realm = try Realm()
            try realm.write {
                for item in favoriteItems.value {
                    item.favoriteData.hasShown = false
                    item.favoriteData.hasMemorized = false
                    realm.add(item.favoriteData, update: .modified)
                }
            }
            
        } catch {
            shLog("\(error) \(error.localizedDescription)")
        }
    }
    
    ///특정 카드의 학습상태를 되돌린다. index가 되돌려질 카드 인 것을 주의
    func revertCardStatus(at index: Int) {
        guard index >= 0, index < cardList.value.count else { shLog("오류: 오버레인지"); return  }
        let item = cardList.value[index]
        
        item.favoriteData.hasMemorized ? (yesCardCount.send(yesCardCount.value - 1)) : (noCardCount.send(noCardCount.value - 1))
        remainCardCount.send(remainCardCount.value + 1)
        do {
            let realm = try Realm()
            
            try realm.write {
                item.favoriteData.hasShown = false
                item.favoriteData.hasMemorized = false
                realm.add(item.favoriteData, update: .modified)
            }
        } catch {
            shLog("\(error) \(error.localizedDescription)")
        }
        
    }
    
    ///카드 학습표시 및 암기 유무를  체크한다.
    func markMemorized(at index: Int, _ isMemorized: Bool) {
        guard index < cardList.value.count else { shLog("오류: 오버레인지"); return  }
        let item = cardList.value[index]
        
        isMemorized ? (yesCardCount.send(yesCardCount.value + 1)) : (noCardCount.send(noCardCount.value + 1))
        remainCardCount.send(remainCardCount.value - 1)
        
        do {
            let realm = try Realm()
            try realm.write {
                item.favoriteData.hasShown = true
                item.favoriteData.hasMemorized = isMemorized
                realm.add(item.favoriteData, update: .modified)
            }
        } catch {
            shLog("\(error) \(error.localizedDescription)")
        }
   
    }
    
    ///favorite를 선택, 해제 한다.
    func markFavorite(at index: Int, _ isFavorite: Bool) {
        guard index < cardList.value.count else { shLog("오류: 오버레인지"); return  }
        let favoriteItem = cardList.value[index]
        favoriteItem.updateFavorite(isFavorite)
    }
    
}

