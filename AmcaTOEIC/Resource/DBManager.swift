//
//  DBManager.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 12/22/24.
//

import Foundation
import RealmSwift

class DBManager {
    static let shared = DBManager()
    private init() { }

    var cardPacks: [CardPack] = []
    var totalCardItems: [CardItem] = []
    
    func initRealm() {
      
        ///objectID 이미그레이션(업데이트) 필요여부
        var isUpdateObjectIdNeeded = false
    
        let config = Realm.Configuration(schemaVersion: 2, migrationBlock: { migration, oldSchemaVersion in
            shLog("oldSchemaVersion: \(oldSchemaVersion)")
            isUpdateObjectIdNeeded = true
            self.loadCardsFromJson()
            if oldSchemaVersion < 2 {
                var totalCount = 0
                var successCount = 0
                var errorCount = 0
                
                //속성 확장 시작
                migration.enumerateObjects(ofType: CardItem.className()){ oldCardItem, newCardItem in
                    
                    if let oldCardItem,
                       let newCardItem,
                       var character: String = oldCardItem["frontWord"] as? String {
                        
                        if character == "册" { //책 책 한자 수정
                            let newChar = "冊"
                            character = newChar
                            newCardItem["frontWord"] = newChar
                        }
                        
                        if let newData = self.totalCardItems.first(where: { $0.frontWord == character }) {
                            newCardItem["backWord"] = newData.backWord
                            newCardItem["radical"] = newData.radical
                            newCardItem["radicalMeaning"] = newData.radicalMeaning
                            newCardItem["strokeCount"] = newData.strokeCount
                            newCardItem["backDesc"] = newData.backDesc
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
                
                shLog("속성확장 완료: totalCount: \(totalCount), successCount: \(successCount), errorCount:\(errorCount) ")
                
            }
        })
        
        
        // Use this configuration when opening realms
        Realm.Configuration.defaultConfiguration = config
        shLog("realm 위치: \(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")")

    }
    
    ///전체 카드 리스트를, CardPack  JSON에서 불러온다
    private func loadCardsFromJson() {
        do {
            cardPacks = try JSONSerialization.loadJSONFromFile(filename: "CardPacks_20241231", type: [CardPack].self)
            totalCardItems = cardPacks.reduce([CardItem](), { $0 + $1.cardList })
            shLog("전체 카드 데이터 JSON 로드 완료: \(totalCardItems.count)개")
        } catch(let error) {
            cardPacks = []
            totalCardItems = []
            shLog(error.localizedDescription)
        }
    }
    
}
