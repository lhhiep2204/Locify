//
//  CategoryRepositoryProtocol.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

protocol CategoryRepositoryProtocol: Sendable {
    func fetchCategories() async throws -> [Category]
    func addCategory(_ category: Category) async throws -> Category
    func updateCategory(_ category: Category) async throws -> Category
    func deleteCategory(_ category: Category) async throws -> Category
}
