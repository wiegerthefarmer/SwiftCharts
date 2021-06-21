//
//  ChartPoint.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPoint: Hashable, Equatable, CustomStringConvertible {
    
    public let x: ChartAxisValue
    public let y: ChartAxisValue
    public let emoji: String
    
    required public init(x: ChartAxisValue, y: ChartAxisValue) {
        self.x = x
        self.y = y
        self.emoji = ""
    }
    
    public init(x: ChartAxisValue, y: ChartAxisValue, emoji: String) {
        self.x = x
        self.y = y
        self.emoji = emoji
    }
    
    open var description: String {
        return "\(x), \(y)"
    }
    
    open func hash(into hasher: inout Hasher) {
        let hash = 31 &* x.hashValue &+ y.hashValue
        hasher.combine(hash)
    }
}

public func ==(lhs: ChartPoint, rhs: ChartPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
