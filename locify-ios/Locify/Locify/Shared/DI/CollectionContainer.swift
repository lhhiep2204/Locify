//
//  CollectionContainer.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 26/10/25.
//

import Foundation

/// Dependency container responsible for Collection feature setup.
///
/// Provides repositories, use cases, and ViewModel factories related to Collection operations.
final class CollectionContainer {
    // MARK: - Repository
    private let repository: CollectionRepositoryProtocol

    // MARK: - Use Cases
    private(set) lazy var fetchUseCase = FetchCollectionsUseCase(repository: repository)
    private(set) lazy var addUseCase = AddCollectionUseCase(repository: repository)
    private lazy var updateUseCase = UpdateCollectionUseCase(repository: repository)
    private lazy var deleteUseCase = DeleteCollectionUseCase(repository: repository)

    private lazy var useCases = CollectionUseCases(
        fetch: fetchUseCase,
        add: addUseCase,
        update: updateUseCase,
        delete: deleteUseCase
    )

    // MARK: - Initialization
    init(repository: CollectionRepositoryProtocol = CollectionRepository()) {
        self.repository = repository
    }
}

// MARK: - ViewModel Factories
extension CollectionContainer {
    func makeCollectionListViewModel() -> CollectionListViewModel {
        CollectionListViewModel(collectionUseCases: useCases)
    }

    func makeEditCollectionViewModel() -> EditCollectionViewModel {
        EditCollectionViewModel()
    }
}
