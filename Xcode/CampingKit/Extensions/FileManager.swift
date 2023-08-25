//
//  FileManager.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation

internal extension FileManager {
    
    var cachesDirectory: URL? {
        return urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    var documentDirectory: URL? {
        return urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
