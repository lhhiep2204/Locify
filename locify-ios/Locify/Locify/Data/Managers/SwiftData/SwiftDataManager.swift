//
//  SwiftDataManager.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/2/26.
//

import Foundation
import SwiftData

/// Protocol for SwiftData operations to enable testing and abstraction.
protocol SwiftDataManaging {
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T]
    func fetchOne<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> T?
    func insert<T: PersistentModel>(_ item: T) throws
    func delete<T: PersistentModel>(_ item: T) throws
    func save() throws
}

/// Manager for handling SwiftData operations.
/// Centralizes all SwiftData CRUD operations to reduce duplication across data sources.
final class SwiftDataManager: SwiftDataManaging {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Fetch multiple items using a FetchDescriptor.
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        try modelContext.fetch(descriptor)
    }

    /// Fetch a single item using a FetchDescriptor.
    func fetchOne<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> T? {
        try modelContext.fetch(descriptor).first
    }

    /// Insert a new item into the context.
    func insert<T: PersistentModel>(_ item: T) throws {
        modelContext.insert(item)
        try save()
    }

    /// Delete an item from the context.
    func delete<T: PersistentModel>(_ item: T) throws {
        modelContext.delete(item)
        try save()
    }

    /// Save changes to the persistent store.
    func save() throws {
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
}

// MARK: - Convenience Query Methods

extension SwiftDataManager {
    /// Fetch all items of a type with optional sorting.
    func fetchAll<T: PersistentModel>(
        _ type: T.Type,
        sortBy: [SortDescriptor<T>] = []
    ) throws -> [T] {
        let descriptor = FetchDescriptor<T>(sortBy: sortBy)
        return try fetch(descriptor)
    }

    /// Delete all items of a specific type.
    func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let items = try fetchAll(type)
        for item in items {
            modelContext.delete(item)
        }
        try save()
    }

    /// Count items matching a predicate.
    func count<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> Int {
        try fetch(descriptor).count
    }

    /// Batch insert multiple items.
    func batchInsert<T: PersistentModel>(_ items: [T]) throws {
        for item in items {
            modelContext.insert(item)
        }
        try save()
    }

    /// Batch delete multiple items.
    func batchDelete<T: PersistentModel>(_ items: [T]) throws {
        for item in items {
            modelContext.delete(item)
        }
        try save()
    }
}
