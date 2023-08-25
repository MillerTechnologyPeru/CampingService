//
//  Schedule.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation
import CoreModel

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

// MARK: - Localization

public extension Schedule {
    
    func localizedDescription(locale: Locale = .current) -> (start: String, end: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.locale = locale
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        let startTime = TimeInterval(start * 60)
        let endTime = TimeInterval(end * 60)
        let start = dateFormatter.string(from: Date(timeIntervalSince1970: startTime))
        let end = dateFormatter.string(from: Date(timeIntervalSince1970: endTime))
        return (start, end)
    }
}

// MARK: - CoreModel

extension Schedule: AttributeEncodable {
    
    public var attributeValue: AttributeValue {
        return .string("\(start),\(end)")
    }
}

extension Schedule: AttributeDecodable {
    
    public init?(attributeValue: AttributeValue) {
        guard let string = String(attributeValue: attributeValue) else {
            return nil
        }
        let components = string.components(separatedBy: ",")
        guard components.count == 2,
            let start = UInt(components[0]),
            let end = UInt(components[1]) else {
            return nil
        }
        self.init(start: start, end: end)
    }
}
