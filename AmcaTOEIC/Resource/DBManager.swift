//
//  DBManager.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 12/22/24.
//

import Foundation
import RealmSwift

class DBManager {
    static let dataJSONFileName = "TOEIC_CardDATA_20250328-213629"
    static let schemaVersion: UInt64 = 7
    
    static let shared = DBManager()
    private init() { }

    var cardPacks: [CardPack] = []
    var totalCardItems: [CardItem] = []
    
    
    func initRealm(completion: @escaping () -> Void) {
        
        let config = Realm.Configuration(schemaVersion: Self.schemaVersion, migrationBlock: { migration, oldSchemaVersion in
            shLog("oldSchemaVersion: \(oldSchemaVersion)")
            self.loadCardsFromJson()
            
            var totalCount = 0
            var successCount = 0
            var errorCount = 0
            
            //속성 확장 시작
            migration.enumerateObjects(ofType: CardItem.className()){ oldCardItem, newCardItem in
                
                if let oldCardItem,
                   let newCardItem,
                   let id = oldCardItem["_id"] as? ObjectId {
                    
                    if let newData = self.totalCardItems.first(where: { $0._id == id }) {
                        newCardItem["index"] = newData.index
                        newCardItem["level"] = newData.level
                        newCardItem["frontWord"] = newData.frontWord
                        newCardItem["backWord"] = newData.backWord
                        newCardItem["backWord02"] = newData.backWord02
                        newCardItem["example01"] = newData.example01
                        newCardItem["examTrans01"] = newData.examTrans01
                        newCardItem["example02"] = newData.example02
                        newCardItem["examTrans02"] = newData.examTrans02
                        successCount += 1
                    } else {
                        shLog("업데이트 오류: oldCardItem: \(String(describing: oldCardItem)), newCardItem: \(String(describing: newCardItem)), character: \(String(describing: oldCardItem["frontWord"]) )")
                        errorCount += 1
                    }
                } else {
                    shLog("업데이트 오류: oldCardItem: \(String(describing: oldCardItem)), newCardItem: \(String(describing: newCardItem)), character: \(String(describing: oldCardItem?["frontWord"]) )")
                    errorCount += 1
                }
                totalCount += 1
            }
            
            shLog("카드 속성 확장 완료: totalCount: \(totalCount), successCount: \(successCount), errorCount:\(errorCount) ")
        })
        
        
        // Use this configuration when opening realms
        Realm.Configuration.defaultConfiguration = config
        shLog("realm 위치: \(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")")
        
        do {
            let realm = try Realm() // 이 시점에서 마이그레이션 수행됨 (필요 시)
            self.updateCardPack()
        } catch {
            print("Realm 초기화 에러: \(error)")
        }
        

        completion()
        
    }
    
    func updateCardPack() {
        var dbCardPackList = [CardPack]()
        let jsonCardPackList = self.cardPacks
        
        do {
            let realm = try Realm()
            let results = realm.objects(CardPack.self)
            dbCardPackList =  Array(results)
            shLog("카드 데이터 준비 완료")
        } catch {
            shLog("Error retrieving data from Realm: \(error)")
            dbCardPackList = []
        }
        

        for (index, jsonCardPack) in jsonCardPackList.enumerated() {
            //모든 카드팩에 대해 실행
            
            if index < dbCardPackList.count {
                //기존에 존재하는 카드팩
                let dbCardPack = dbCardPackList[index]
                shLog("dbCardPack: \(dbCardPack.level)에 대해 업데이트  시작")
                do {
                    let realm = try Realm()
                    
                    try realm.write {
                        ///모든 목록 제거
                        dbCardPack.cardList.removeAll()
                        
                        var totalCount = 0
                        var dbCardCount = 0
                        ///json 카드목록 기준으로 db에서 카드아이템을 찾아서 cardList에 할당.
                        for jsonCardItem in jsonCardPack.cardList {
                            totalCount += 1
                            if let dbCardItem = realm.object(ofType: CardItem.self, forPrimaryKey: jsonCardItem._id) {
                                
                                dbCardPack.cardList.append(dbCardItem)
                                dbCardCount += 1
                            } else {
                                
                                dbCardPack.cardList.append(jsonCardItem)
                            }
                            
                        }
                        shLog("dbCardPack: \(dbCardPack.level)에 대한 totalCard:\(totalCount)개(기존 dbCard \(dbCardCount)개) 업데이트 완료")
                    }
                    
                } catch {
                    shLog("dbCardPack: \(dbCardPack.level)에 대해 업데이트  실패")
                }
            } else {
                //기존에 존재안하는 카드팩
                do {
                    let realm = try Realm()
                    
                    var newCardList : [CardItem] = []
                    for jsonCardItem in jsonCardPack.cardList {
                        if let dbCardItem = realm.object(ofType: CardItem.self, forPrimaryKey: jsonCardItem._id) {
                            newCardList.append(dbCardItem)
                        } else {
                            
                            newCardList.append(jsonCardItem)
                        }
                        
                    }
                    jsonCardPack.cardList.removeAll()
                    jsonCardPack.cardList.append(objectsIn: newCardList)
                    
                    try realm.write {
                        realm.add(jsonCardPack)
                    }
                    shLog("새로운 카드팩(level: \(jsonCardPack.level)) 삽입 완료")
                } catch {
                    
                }
            }
        }
    }
    
    ///전체 카드 리스트를, CardPack  JSON에서 불러온다
   func loadCardsFromJson() {
        do {
            cardPacks = try JSONSerialization.loadJSONFromFile(filename: Self.dataJSONFileName , type: [CardPack].self)
            totalCardItems = cardPacks.reduce([CardItem](), { $0 + $1.cardList })
            shLog("전체 카드 데이터 JSON 로드 완료: \(totalCardItems.count)개")
        } catch(let error) {
            cardPacks = []
            totalCardItems = []
            shLog(error.localizedDescription)
        }
    }
    
    ///DB의 카드목록을 불러온다
    func fetchCardPackCardList() {
        do {
            let realm = try Realm()
            let results = realm.objects(CardPack.self)
            cardPacks =  Array(results)
            totalCardItems = cardPacks.reduce([CardItem](), { $0 + $1.cardList })
            shLog("카드 데이터 준비 완료")
        } catch {
            shLog("Error retrieving data from Realm: \(error)")
            cardPacks = []
            totalCardItems = []
        }
    }
    
    
    ///DB를 JSON에서 불러와서 저장한다.
    func initCardPackDBFromJson() {
        do {
            let cardPackList = try JSONSerialization.loadJSONFromFile(filename: DBManager.dataJSONFileName, type: [CardPack].self)
            let realm = try Realm()
            try realm.write {
                realm.add(cardPackList)
            }
            shLog("카드데이터 JSON -> Realm 삽입 완료: \(cardPackList.count)개")
        } catch(let error) {
            shLog(error.localizedDescription)
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
    
    func checkCardPackDBExists() -> Bool {
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
    

    
}
