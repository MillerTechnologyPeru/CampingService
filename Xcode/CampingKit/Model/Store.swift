//
//  Store.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import Foundation
import Combine
import CampingService

@MainActor
public final class Store: ObservableObject {
    
    // MARK: - Properties
    
    public let server: CampingServer
    
    internal let isKeychainEnabled: Bool
    
    internal lazy var fileManager = FileManager()
    
    internal lazy var preferences = loadPreferences()
    
    internal var preferencesObserver: AnyCancellable?
    
    internal lazy var passwordKeychain = loadPasswordKeychain()
    
    internal lazy var tokenKeychain = loadTokenKeychain()
    
    internal lazy var urlSession = loadURLSession()
    
    // MARK: - Initialization
    
    public init(server: CampingServer) {
        self.server = server
        #if KEYCHAIN
        self.isKeychainEnabled = true
        #else
        self.isKeychainEnabled = false
        #endif
    }
    
    internal init(
        isKeychainEnabled: Bool,
        server: CampingServer
    ) {
        self.server = server
        self.isKeychainEnabled = isKeychainEnabled
    }
    
    #if DEBUG
    internal static let preview = Store(
        isKeychainEnabled: false,
        server: .localhost(port: 8080)
    )
    #endif
    
    deinit {
        preferencesObserver?.cancel()
    }
}
