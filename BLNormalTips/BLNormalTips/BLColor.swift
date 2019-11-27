//
//  BLColor.swift
//  BLNormalTips
//
//  Created by 王春龙 on 2019/11/7.
//  Copyright © 2019 王春龙. All rights reserved.
//

import UIKit

struct Color {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
}

struct BLColor: Hashable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    
    // Synthesized by compiler
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.red)
        hasher.combine(self.green)
        hasher.combine(self.blue)
    }
    
    // Default implementation from protocol extension
    var hashValue: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
}

extension Color: Equatable {

    static func == (lhs: Color, rhs: Color) -> Bool {
        
        return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
    }
}

extension Color : Hashable {
   
    var hashValue: Int {
        return self.red.hashValue ^ self.green.hashValue ^ self.blue.hashValue
    }
}
