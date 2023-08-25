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
    
    @StateObject
    var viewModel: ViewModel
    
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
        query: String = "",
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
        let viewModel = ViewModel(
            store: store,
            cache: cache,
            query: query,
            sort: sort,
            ascending: ascending,
            limit: limit,
            state: data.map { .success($0) } ?? .loading
        )
        self._viewModel = .init(wrappedValue: viewModel)
        self.loadingContent = loadingContent
        self.emptyContent = emptyContent
        self.errorContent = errorContent
        self.rowContent = rowContent
        self.rowPlaceholder = rowPlaceholder
        self.rowError = rowError
    }
    
    public var body: some View {
        ZStack {
            switch viewModel.state {
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
                            store: viewModel.store,
                            cache: viewModel.cache,
                            row: rowContent,
                            placeholder: rowPlaceholder,
                            error: rowError
                        )
                    }
                    .refreshable {
                        await viewModel.refreshData()
                    }
                }
            }
        }
        .searchable(text: $viewModel.query)
        .onAppear {
            Task {
                await viewModel.refreshData()
            }
        }
    }
}

internal extension EntityQueryListView {
    
    final class ViewModel: ObservableObject {
        
        let store: Store
        
        let cache: (Entity.ID) -> (Entity?)
        
        @Published
        var query: String {
            didSet { queryChanged() }
        }
        
        let sort: Entity.CodingKeys
        
        let ascending: Bool
        
        let limit: UInt
        
        @Published
        var state: ViewState = .loading
        
        @Published
        private var task: Task<Void, Never>?
        
        init(
            store: Store,
            cache: @escaping (Entity.ID) -> (Entity?),
            query: String,
            sort: Entity.CodingKeys,
            ascending: Bool,
            limit: UInt,
            state: ViewState = .loading
        ) {
            self.store = store
            self.cache = cache
            self.query = query
            self.sort = sort
            self.ascending = ascending
            self.limit = limit
            self.state = state
        }
        
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
        
        func queryChanged() {
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
    
    enum ViewState {
        case loading
        case failure(Error)
        case success([Entity.ID])
    }
}
