//
//  Locale.swift
//  
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import Foundation

internal extension Locale {
    
    var _languageCode: String {
        #if canImport(Darwin)
        if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
            return language.minimalIdentifier
        } else {
            return languageCode ?? "en"
        }
        #else
        return languageCode ?? "en"
        #endif
    }
}
