//
//  CardSideType.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 5/6/24.
//

import Foundation

enum CardSideType: Int {
    case front = 0
    case back = 1
    
    var reversed: Self {
        return self == .front ? .back : .front
    }
}
