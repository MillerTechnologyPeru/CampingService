//
//  Schedule.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation

/// Schedule (e.g. Check in, Check Out)
public struct Schedule: Equatable, Hashable, Codable {
    
    public var start: UInt
    
    public var end: UInt
    
    public init(start: UInt, end: UInt) {
        assert(start < end)
        self.start = start
        self.end = end
    }
}
