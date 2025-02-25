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
        if always || !checkCardPackDBExists() {
            deleteAllDataFromRealm()
            initCardPackDBFromJson()
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
    
    ///DB를 JSON에서 불러와서 저장한다.
    private func initCardPackDBFromJson() {
        do {
            let cardPackList = try JSONSerialization.loadJSONFromFile(filename: "CardPacks_20241231", type: [CardPack].self)
            let realm = try Realm()
            try realm.write {
                realm.add(cardPackList)
            }
            shLog("카드데이터 JSON -> Realm 삽입 완료: \(cardPackList.count)개")
        } catch(let error) {
            shLog(error.localizedDescription)
        }
    }
    
    private func checkCardPackDBExists() -> Bool {
        do {
            // Realm 설정
            let realm = try Realm()
            
            // YourObject 클래스에 해당하는 객체들을 쿼리하여 결과 확인
            let objects = realm.objects(CardPack.self)
            if objects.count > 0 {
                shLog("카드데이터 있음: \(objects.count)개")
                return true
            } else {
                shLog("카드데이터 없음")
                return false
            }
            
        } catch(let error) {
            shLog(error.localizedDescription)
            return false
        }
    }
    
    func deleteAllDataFromRealm() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
            shLog("카드 데이터 모두 삭제 완료")
        } catch {
            shLog("Error deleting data from Realm: \(error)")
        }
    }
    
    func resetLearningStatus(at index: Int ) {
        let item = cardPackList[index]
        item.setLearningStatus(.notStarted)
    }
    
}

