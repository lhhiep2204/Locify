//
//  CategoryRepositoryProtocol.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

protocol CategoryRepositoryProtocol: Sendable {
    func fetchCategories() async throws -> [Category]
}
