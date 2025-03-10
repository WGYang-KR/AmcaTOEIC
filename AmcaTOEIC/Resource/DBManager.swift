//
//  DBManager.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 12/22/24.
//

import Foundation
import RealmSwift

class DBManager {
    static let dataJSONFileName = "TOEIC_CardDATA_20250308-085306"
    static let schemaVersion: UInt64 = 3
    
    static let shared = DBManager()
    private init() { }

    var cardPacks: [CardPack] = []
    var totalCardItems: [CardItem] = []
    
    
    func initRealm() {
      
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
                        newCardItem["frontWord"] = newData.frontWord
                        newCardItem["backWord"] = newData.backWord
                        newCardItem["backWord02"] = newData.backWord02
                        newCardItem["example01"] = newData.example01
                        newCardItem["example02"] = newData.example02
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
            
            shLog("데이터 업데이트 완료: totalCount: \(totalCount), successCount: \(successCount), errorCount:\(errorCount) ")
            
            
        })
        
        // Use this configuration when opening realms
        Realm.Configuration.defaultConfiguration = config
        shLog("realm 위치: \(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")")
    }
    
    ///전체 카드 리스트를, CardPack  JSON에서 불러온다
    private func loadCardsFromJson() {
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
    
}
