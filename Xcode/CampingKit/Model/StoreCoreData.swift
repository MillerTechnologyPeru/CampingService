//
//  StoreCoreData.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/25/23.
//

import Foundation
import CoreData
import CoreModel
import CoreDataModel

public extension Store {
    
    func loadPersistentStores() async {
        guard didLoadPersistentStores == false else {
            return
        }
        do {
            for try await store in persistentContainer.loadPersistentStores() {
                log("Loaded CoreData store \(store.url?.absoluteString ?? "")", category: .persistence)
            }
            didLoadPersistentStores = true
        }
        catch {
            logError(error, category: .persistence)
            // remove sqlite file at url
            for url in persistentContainer.persistentStoreDescriptions.compactMap({ $0.url }) {
                try? fileManager.removeItem(at: url)
            }
            // try again
            await loadPersistentStores()
        }
    }
}

internal extension Store {
    
    func loadPersistentContainer() -> NSPersistentContainer {
        guard let url = fileManager.cachesDirectory?.appendingPathComponent(persistentStoreName + ".sqlite") else {
            fatalError("Missing caches directory")
        }
        let container = NSPersistentContainer(
            name: persistentStoreName,
            managedObjectModel: .init(model: .camping)
        )
        let storeDescription = NSPersistentStoreDescription(url: url)
        storeDescription.shouldInferMappingModelAutomatically = true
        storeDescription.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions = [storeDescription]
        return container
    }
    
    func loadViewContext() -> NSManagedObjectContext {
        let context = self.persistentContainer.viewContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        context.undoManager = nil
        return context
    }
    
    func loadBackgroundContext() -> NSManagedObjectContext {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        context.undoManager = nil
        return context
    }
    
    func commit(_ block: @escaping (NSManagedObjectContext) throws -> ()) async throws {
        // load persist store
        await loadPersistentStores()
        // modify background context
        let context = self.backgroundContext
        assert(context.concurrencyType == .privateQueueConcurrencyType)
        try await context.perform { [unowned context, unowned self] in
            context.reset()
            // run closure
            do {
                try block(context)
            }
            catch {
                if context.hasChanges {
                    context.undo()
                }
                throw error
            }
            // attempt to save
            do {
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                logError(error, category: .persistence)
                assertionFailure("Core Data error. \(error)")
                throw error
            }
        }
        // update SwiftUI that doesnt use FRC
        self.objectWillChange.send()
    }
}
