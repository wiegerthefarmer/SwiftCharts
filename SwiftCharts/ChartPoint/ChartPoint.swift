//
//  ChartPoint.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPoint: Hashable, Equatable, CustomStringConvertible, Comparable {
    public static func < (lhs: ChartPoint, rhs: ChartPoint) -> Bool {
        return lhs.x < rhs.x
    }
    
    public let x: ChartAxisValue
    public let y: ChartAxisValue
    public let emoji: String
    public let slope: String
    
    required public init(x: ChartAxisValue, y: ChartAxisValue) {
        self.x = x
        self.y = y
        self.emoji = ""
        self.slope = ""
    }
    
    public init(x: ChartAxisValue, y: ChartAxisValue, emoji: String, slope: String) {
        self.x = x
        self.y = y
        self.emoji = emoji
        self.slope = slope
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

public func >(lhs: ChartPoint, rhs: ChartPoint) -> Bool {
    return lhs.x > rhs.x
}
