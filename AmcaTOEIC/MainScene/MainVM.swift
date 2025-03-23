//
//  MainVM.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 5/1/24.
//

import Foundation
import RealmSwift

class MainVM {
    
    ///카드팩
    var cardPackList: [CardPack] = []

    ///DB존재 여부를 체크하고 없으면 초기화한다. always면 항상 초기화한다.
    func initCardPackIfNeeded(always: Bool = false) {
        shLog("always: \(always)")
        if always || !DBManager.shared.checkCardPackDBExists() {
            DBManager.shared.deleteAllDataFromRealm()
            DBManager.shared.initCardPackDBFromJson()
        }

    }
    
    ///DB의 카드목록을 불러온다
    func prepareCardPackList() {
        do {
            let realm = try Realm()
            let results = realm.objects(CardPack.self)
            cardPackList =  Array(results)
            shLog("카드 데이터 준비 완료")
        } catch {
            shLog("Error retrieving data from Realm: \(error)")
            cardPackList = []
        }
    }
    
    func resetStudyProgress() {
        do {
            let realm = try Realm()
            let results = realm.objects(CardPack.self)
            try realm.write {
                for cardPack in results {
                    for item in cardPack.cardList {
                        item.hasShown = false
                        item.hasMemorized = false
                    }
                }
                realm.add(results, update: .modified)
                
            }
        } catch{
            shLog("Error retrieving data from Realm: \(error)")
        }
    }
    
 
    func resetLearningStatus(at index: Int ) {
        let item = cardPackList[index]
        item.setLearningStatus(.notStarted)
    }
    
}

