//
//  FavoriteData.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 6/25/24.
//

import Foundation
import RealmSwift

//CardItem을 품고 별도의 hasShown hasMemorized 정보를 추가로 가진 객체
class FavoriteData: Object {

    ///현 아이템을 참조하고 있는 부모 CardItem
    @Persisted(originProperty: "favoriteData") var parentCardItem: LinkingObjects<CardItem>
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var timestamp = Date()
    @Persisted var hasShown: Bool = false
    @Persisted var hasMemorized: Bool = false
    
}
