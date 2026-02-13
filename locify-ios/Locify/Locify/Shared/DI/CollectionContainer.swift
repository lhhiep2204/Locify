//
//  CollectionContainer.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 26/10/25.
//

import Foundation

final class CollectionContainer {
    // MARK: - Data Source
    private let localDataSource: CollectionLocalDataSourceProtocol

    // MARK: - Mapper
    private let collectionMapper: CollectionMapping

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

    init(
        localDataSource: CollectionLocalDataSourceProtocol? = nil,
        collectionMapper: CollectionMapping = CollectionMapper(),
        repository: CollectionRepositoryProtocol? = nil
    ) {
        let swiftDataManager = SwiftDataContainer.shared.makeMainManager()

        self.localDataSource = localDataSource ?? CollectionLocalDataSource(
            swiftDataManager: swiftDataManager
        )

        self.collectionMapper = collectionMapper

        self.repository = repository ?? CollectionRepository(
            localDataSource: self.localDataSource,
            collectionMapper: collectionMapper
        )
    }

    // MARK: - ViewModel Factories
    func makeCollectionListViewModel() -> CollectionListViewModel {
        CollectionListViewModel(collectionUseCases: useCases)
    }

    func makeEditCollectionViewModel() -> EditCollectionViewModel {
        EditCollectionViewModel()
    }
}
