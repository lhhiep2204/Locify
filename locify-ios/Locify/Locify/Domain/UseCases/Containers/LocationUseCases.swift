//
//  LocationUseCases.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 30/7/25.
//

import Foundation

struct LocationUseCases {
    let fetch: FetchLocationsUseCaseProtocol
    let add: AddLocationUseCaseProtocol
    let update: UpdateLocationUseCaseProtocol
    let delete: DeleteLocationUseCaseProtocol
}
