//
//  CategoryUseCases.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 30/7/25.
//

import Foundation

struct CategoryUseCases {
    let fetch: FetchCategoriesUseCaseProtocol
    let add: AddCategoryUseCaseProtocol
    let update: UpdateCategoryUseCaseProtocol
    let delete: DeleteCategoryUseCaseProtocol
}
