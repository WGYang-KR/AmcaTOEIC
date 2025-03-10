//
//  CardItem.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 4/18/24.
//

import Foundation
import RealmSwift

final class CardItem: Object, Decodable {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var index: Int
    @Persisted var level: Int
    @Persisted var frontWord: String
    @Persisted var pronunciation: String
    @Persisted var backWord: String
    @Persisted var backWord02: String
    @Persisted var example01: String
    @Persisted var example02: String
    
    @Persisted var hasShown: Bool
    @Persisted var hasMemorized: Bool
    @Persisted var isFavorite: Bool = false
    ///favorite를 true로 바꿀 때 생성되는 favoriteData이다. 별도의 hasShown, hasMemorized 정보가 만들어진다.
    @Persisted var favoriteData: FavoriteData?

    override init() {
        super.init()
    }
    
    deinit { }
    
    //MARK: - Decodable
    enum CodingKeys: String, CodingKey {
        case _id
        case index
        case level
        case frontWord
        
        case pronunciation
        case backWord
        case backWord02
        case example01
        case example02
        
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
        pronunciation = try container.decodeIfPresent(String.self, forKey: .pronunciation) ?? ""
        backWord = try container.decodeIfPresent(String.self, forKey: .backWord) ?? ""
        backWord02 = try container.decodeIfPresent(String.self, forKey: .backWord02) ?? ""
        example01 = try container.decodeIfPresent(String.self, forKey: .example01) ?? ""
        example02 = try container.decodeIfPresent(String.self, forKey: .example02) ?? ""
        hasShown = try container.decodeIfPresent(Bool.self, forKey: .hasShown) ?? false
        hasMemorized = try container.decodeIfPresent(Bool.self, forKey: .hasMemorized) ?? false
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }
    
}
