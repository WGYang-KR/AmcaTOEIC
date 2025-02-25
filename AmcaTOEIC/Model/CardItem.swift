//
//  CardItem.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 4/18/24.
//

import Foundation
import RealmSwift

final class CardItem: Object, Decodable {
    
   
    ///한자ID
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var index: Int
    @Persisted var level: Int
    @Persisted var frontWord: String
    @Persisted var backWord: String
    /// 부수
    @Persisted var radical: String
    /// 부수 뜻, 음
    @Persisted var radicalMeaning: String
    /// 총획수
    @Persisted var strokeCount: Int
    ///한자 뜻 추가 설명
    @Persisted var backDesc: String
    @Persisted var hasShown: Bool
    @Persisted var hasMemorized: Bool
    @Persisted var isFavorite: Bool = false
    ///favorite를 true로 바꿀 때 생성되는 favoriteData이다. 별도의 hasShown, hasMemorized 정보가 만들어진다.
    @Persisted var favoriteData: FavoriteData?

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
        case frontWord
        case backWord
        case radical
        case radicalMeaning
        case strokeCount
        case backDesc
        case hasShown
        case hasMemorized
        case isFavorite
        
    }
    
    init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(ObjectId.self, forKey: ._id)
        index = try container.decodeIfPresent(Int.self, forKey: .index) ?? 0
        level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 0
        frontWord = try container.decodeIfPresent(String.self, forKey: .frontWord) ?? ""
        backWord = try container.decodeIfPresent(String.self, forKey: .backWord) ?? ""
        radical = try container.decodeIfPresent(String.self, forKey: .radical) ?? ""
        radicalMeaning = try container.decodeIfPresent(String.self, forKey: .radicalMeaning) ?? ""
        strokeCount = try container.decodeIfPresent(Int.self, forKey: .strokeCount) ?? 0
        backDesc = try container.decodeIfPresent(String.self, forKey: .backDesc) ?? ""
        hasShown = try container.decodeIfPresent(Bool.self, forKey: .hasShown) ?? false
        hasMemorized = try container.decodeIfPresent(Bool.self, forKey: .hasMemorized) ?? false
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }
    
}
