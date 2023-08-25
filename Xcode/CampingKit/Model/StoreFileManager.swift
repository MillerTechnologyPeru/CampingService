//
//  StoreFileManager.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation

internal extension Store {
    
    func url(for file: StoreFile) -> URL {
        guard let containerURL = fileManager.cachesDirectory
            else { fatalError("Could not open Caches directory"); }
        return containerURL.appendingPathComponent(file.rawValue)
    }
}

internal enum StoreFile: String {
    
    case cacheJSON      = "data.json"
    case cacheSqlite    = "data.sqlite"
}
