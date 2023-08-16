//
//  JSON.swift
//  
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import Foundation

public extension JSONDecoder {
    
    static var camping: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

public extension JSONEncoder {
    
    static var camping: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
