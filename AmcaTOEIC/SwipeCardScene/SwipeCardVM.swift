//
//  SwipeCardService.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 4/25/24.
//

import Foundation
import Combine
import RealmSwift

class SwipeCardVM {
    
    ///카드팩
    let cardPack: CardPack
    
    ///현재 학습중인 카드리스트
    let cardList = CurrentValueSubject<[CardItem],Never>([])
    ///학습중인 전체 카드 개수
    let totalCardCount = CurrentValueSubject<Int,Never>(0)
    ///미학습 카드 개수
    let remainCardCount = CurrentValueSubject<Int,Never>(0)
    ///암기 카드 카운트
    let yesCardCount = CurrentValueSubject<Int,Never>(0)
    ///미암기 카드 카운트
    let noCardCount = CurrentValueSubject<Int,Never>(0)
    
    ///카드팩으로 서비스를 init한다.
    init(cardPack: CardPack) {
        self.cardPack = cardPack
    }
    
    ///미학습 또는 미암기 카드만 추출하여 카드리스트를 준비한다.
    func prepareCardList(shuffle: Bool) {
        let fetchedCardList: [CardItem] = cardPack.cardList.filter { !$0.hasMemorized || !$0.hasShown }
        cardList.send(shuffle ? fetchedCardList.shuffled() : fetchedCardList )
        totalCardCount.send(cardList.value.count)
        remainCardCount.send(cardList.value.count)
        yesCardCount.send(0)
        noCardCount.send(0)
    }

    
    ///모든 카드의 학습상태  정보를 삭제하고, 카드리스트를 다시 준비한다.
    func deleteStudyStatus() {
        cardPack.setLearningStatus(.notStarted)
    }
    
    ///특정 카드의 학습상태를 되돌린다. index가 되돌려질 카드 인 것을 주의
    func revertCardStatus(at index: Int) {
        guard index >= 0, index < cardList.value.count else { shLog("오류: 오버레인지"); return  }
        let item = cardList.value[index]
        
        item.hasMemorized ? (yesCardCount.send(yesCardCount.value - 1)) : (noCardCount.send(noCardCount.value - 1))
        remainCardCount.send(remainCardCount.value + 1)
        
        let realm = try! Realm()
        
        try! realm.write {
            item.hasShown = false
            item.hasMemorized = false
            realm.add(item, update: .modified)
        }
        
    }
    
    ///카드 학습표시 및 암기 유무를  체크한다.
    func markMemorized(at index: Int, _ isMemorized: Bool) {
        guard index < cardList.value.count else { shLog("오류: 오버레인지"); return  }
        let item = cardList.value[index]
        
        isMemorized ? (yesCardCount.send(yesCardCount.value + 1)) : (noCardCount.send(noCardCount.value + 1))
        remainCardCount.send(remainCardCount.value - 1)
        
        let realm = try! Realm()
        try! realm.write {
            item.hasShown = true
            item.hasMemorized = isMemorized
            realm.add(item, update: .modified)
        }
   
    }
    
    func markFavorite(at index: Int, _ isFavorite: Bool) {
        guard index < cardList.value.count else { shLog("오류: 오버레인지"); return  }
        let item = cardList.value[index]
        
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
                    let favoriteData = item.favoriteData
                    item.isFavorite = false
                    item.favoriteData = nil
                    realm.add(item, update: .modified)
                    
                    
                    //FavoriteData 삭제
                    guard let favoriteData else {
                        shLog("Favorite 삭제 실패: \(item.frontWord)의 favoriteData가 없음")
                        return
                    }
                    
                    realm.delete(favoriteData)
                    
                }
              
                shLog("Favorite 등록/삭제 완료: \(item.frontWord) to \(isFavorite)")
                
            }
        } catch(let error) {
            shLog(error.localizedDescription)
        }
            
    }
    
    
}
