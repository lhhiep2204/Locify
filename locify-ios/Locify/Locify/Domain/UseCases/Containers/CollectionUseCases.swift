//
//  CollectionUseCases.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 30/7/25.
//

import Foundation

struct CollectionUseCases {
    let fetch: FetchCollectionsUseCaseProtocol
    let add: AddCollectionUseCaseProtocol
    let update: UpdateCollectionUseCaseProtocol
    let delete: DeleteCollectionUseCaseProtocol
}
