//
//  StoreLog.swift
//  
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import Foundation
import OSLog

public extension Store {
    
    func log(
        _ message: String,
        level: OSLogType = .default,
        category: LogCategory = .app
    ) {
        let subsystem = Bundle.main.bundleIdentifier ?? "com.colemancda.CampingKit"
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.log(level: level, "\(message)")
        // TODO: Log to file
        
    }
    
    func logError(
        _ error: Error,
        category: LogCategory = .app,
        file: StaticString = #file,
        function: StaticString = #function
    ) {
        let message: String
        #if DEBUG
        message = "⚠️ " + error.localizedDescription + String(file) + String(function)
        #else
        message = "⚠️ " + error.localizedDescription
        #endif
        log(message, level: .error, category: category)
    }
}

public enum LogCategory: String {
    
    case app
    case networking
    case persistence
    case keychain
}
