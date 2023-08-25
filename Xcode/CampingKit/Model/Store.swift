//
//  Store.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import Foundation
import Combine
import CoreData
import CoreModel
import NetworkObjects
import CampingService

@MainActor
public final class Store: ObservableObject {
    
    // MARK: - Properties
    
    public let server: URL
    
    public let persistentStoreName: String
    
    internal let isKeychainEnabled: Bool
    
    internal lazy var fileManager = FileManager()
    
    internal lazy var preferences = loadPreferences()
    
    internal var preferencesObserver: AnyCancellable?
    
    internal lazy var passwordKeychain = loadPasswordKeychain()
    
    internal lazy var tokenKeychain = loadTokenKeychain()
    
    internal lazy var urlSession = loadURLSession()
    
    internal lazy var networkObjects = NetworkStore<URLSession>(
        server: server,
        client: urlSession,
        encoder: .camping,
        decoder: .camping
    )
    
    public lazy var persistentContainer = loadPersistentContainer()
    
    public lazy var managedObjectContext = loadViewContext()
    
    internal lazy var backgroundContext = loadBackgroundContext()
    
    @Published
    internal var didLoadPersistentStores = false
    
    // MARK: - Initialization
    
    deinit {
        preferencesObserver?.cancel()
    }
    
    public init(
        server: URL,
        persistentStoreName: String = "CampingKit"
    ) {
        self.server = server
        self.persistentStoreName = persistentStoreName
        #if KEYCHAIN
        self.isKeychainEnabled = true
        #else
        self.isKeychainEnabled = false
        #endif
    }
    
    internal init(
        isKeychainEnabled: Bool,
        server: URL,
        persistentStoreName: String = "CampingKit"
    ) {
        self.server = server
        self.isKeychainEnabled = isKeychainEnabled
        self.persistentStoreName = persistentStoreName
    }
    
    #if DEBUG
    public static let preview = Store(
        isKeychainEnabled: false,
        server: URL(string: "http://localhost:8080")!,
        persistentStoreName: "CampingKitPreview-\(UUID())"
    )
    #endif
    
    
}
