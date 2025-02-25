//
//  CardPack.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 4/25/24.
//

import Foundation
import RealmSwift

final class CardPack: Object, Decodable{
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var index: Int
    @Persisted var level: Int
    @Persisted var title: String //한자 9급
    @Persisted var cardList: List<CardItem> // = List<CardItem>()
    
    override init() {
        super.init()
    }
    
    deinit {
        
    }
    
    
    //MARK: - Decodable
    enum CodingKeys: String, CodingKey {
        case _id
        case index
        case level
        case title
        case cardList
    }
    
    init(from decoder: Decoder) throws {
        super.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(ObjectId.self, forKey: ._id)
        index = try container.decodeIfPresent(Int.self, forKey: .index) ?? 0
        level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 0
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        let cardArray = try container.decodeIfPresent([CardItem].self, forKey: .cardList) ?? []
        let newCardList = List<CardItem>()
        for item in cardArray {
            newCardList.append(item)
        }
        cardList = newCardList
       
    }
    
    //MARK: - 
    //샘플데이터용
    internal init(_id: ObjectId, index: Int, level: Int, title: String, cardList: List<CardItem>) {
        super.init()
        self._id = _id
        self.index = index
        self.level = level
        self.title = title
        self.cardList = cardList
        
    }
}

extension CardPack {
    ///총 카드수
    var totalCardCount: Int {
        return cardList.count
    }
    
    ///암기 잔여 카드수
    var remainCardCount: Int {
        return cardList.filter{!$0.hasMemorized}.count
    }
    
    var learningStatus: LearningStatus {
        let remainCardCount = self.remainCardCount
        let totalCardCount = self.totalCardCount
        
        if remainCardCount == 0 { return .completed }
        else if  remainCardCount < totalCardCount {return .inProgress }
        else { return .notStarted }
    }
    
    ///학습정보 초기화
    func setLearningStatus(_ status: LearningStatus) {
        do {
            let realm = try Realm()
            switch status {
            case .notStarted:
                try realm.write {
                    for item in cardList {
                        item.hasShown = false
                        item.hasMemorized = false
                    }
                    realm.add(self, update: .modified)
                }
            case .completed:
                try realm.write {
                    for item in cardList {
                        item.hasShown = true
                        item.hasMemorized = true
                    }
                    realm.add(self, update: .modified)
                }
            case .inProgress:
                break;
                
            }
        } catch {
            shLog("\(error) \(error.localizedDescription)")
        }
    }
    
}
