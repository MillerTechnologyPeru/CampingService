//
//  EntityQueryListView.swift
//  CampingKit
//
//  Created by Alsey Coleman Miller on 8/24/23.
//

import Foundation
import Combine
import SwiftUI
import CoreModel
import NetworkObjects
import NetworkObjectsUI

/// NetworkObjects Searchable Entity List View
public struct EntityQueryListView <Entity: NetworkEntity, Store: ObjectStore, LoadingView: View, ErrorView: View, EmptyContentView: View, RowContent: View, RowPlaceholder: View, RowError: View>  : View {
    
    let store: Store
    
    let cache: (Entity.ID) -> (Entity?)
    
    @Binding
    var query: String {
        didSet { queryChanged(oldValue) }
    }
    
    let sort: Entity.CodingKeys
    
    let ascending: Bool
    
    let limit: UInt
    
    @State
    private var state: ViewState = .loading
    
    @State
    private var task: Task<Void, Never>?
    
    let loadingContent: () -> (LoadingView)
    
    let emptyContent: () -> (EmptyContentView)
    
    let errorContent: (Error) -> (ErrorView)
    
    let rowContent: (Entity) -> (RowContent)
    
    let rowPlaceholder: (Entity.ID) -> (RowPlaceholder)
    
    let rowError: (Error) -> (RowError)
    
    public init(
        data: [Entity.ID]? = nil,
        store: Store,
        cache: @escaping (Entity.ID) -> (Entity?),
        query: Binding<String>,
        sort: Entity.CodingKeys,
        ascending: Bool = true,
        limit: UInt = 0,
        loadingContent: @escaping () -> (LoadingView),
        emptyContent: @escaping () -> (EmptyContentView),
        errorContent: @escaping (Error) -> (ErrorView),
        rowContent: @escaping (Entity) -> (RowContent),
        rowPlaceholder: @escaping (Entity.ID) -> (RowPlaceholder),
        rowError: @escaping (Error) -> (RowError)
    ) {
        let state: ViewState = data.map { .success($0) } ?? .loading
        self._state = .init(initialValue: state)
        self._query = query
        self.store = store
        self.cache = cache
        self.sort = sort
        self.ascending = ascending
        self.limit = limit
        self.loadingContent = loadingContent
        self.emptyContent = emptyContent
        self.errorContent = errorContent
        self.rowContent = rowContent
        self.rowPlaceholder = rowPlaceholder
        self.rowError = rowError
    }
    
    public var body: some View {
        ZStack {
            switch state {
            case .loading:
                loadingContent()
            case .failure(let error):
                errorContent(error)
            case .success(let objectIDs):
                if objectIDs.isEmpty {
                    emptyContent()
                } else {
                    List {
                        ForEachEntity(
                            data: objectIDs,
                            store: store,
                            cache: cache,
                            row: rowContent,
                            placeholder: rowPlaceholder,
                            error: rowError
                        )
                    }
                    .refreshable {
                        await refreshData()
                    }
                }
            }
        }
        .searchable(text: $query)
        .onAppear {
            Task {
                await refreshData()
            }
        }
    }
}

internal extension EntityQueryListView {
    
    func refreshData() async {
        // set new state
        switch state {
        case .loading:
            break
        case .failure:
            self.state = .loading
        case .success(let array):
            if array.isEmpty {
                self.state = .loading
            }
        }
        // cancel previous task
        self.task?.cancel()
        // start loading
        self.task = Task(priority: .userInitiated) {
            do {
                let objectIDs = try await store.query(queryRequest)
                self.state = .success(objectIDs)
            } catch {
                self.state = .failure(error)
            }
        }
        await task?.value
    }
    
    func queryChanged(_ oldValue: String) {
        guard oldValue != self.query else {
            return
        }
        Task(priority: .userInitiated) {
            await refreshData()
        }
    }
    
    var queryRequest: QueryRequest<Entity> {
        QueryRequest<Entity>(
            query: query.isEmpty ? nil : query,
            sort: sort,
            ascending: ascending,
            limit: limit == 0 ? nil : limit,
            offset: nil // TODO: Loading in batches
        )
    }
}

internal extension EntityQueryListView {
    
    enum ViewState {
        case loading
        case failure(Error)
        case success([Entity.ID])
    }
}
