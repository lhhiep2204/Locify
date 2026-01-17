//
//  CollectionRepositoryProtocol.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

protocol CollectionRepositoryProtocol: Sendable {
    func fetchCollections() async throws -> [Collection]
    func addCollection(_ collection: Collection) async throws -> Collection
    func updateCollection(_ collection: Collection) async throws -> Collection
    func deleteCollection(_ collection: Collection) async throws -> Collection
}
