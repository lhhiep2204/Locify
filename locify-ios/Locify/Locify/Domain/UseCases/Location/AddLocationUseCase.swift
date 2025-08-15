//
//  AddLocationUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 14/8/25.
//

import Foundation

protocol AddLocationUseCaseProtocol {
    func execute(_ location: Location) async throws -> Location
}

struct AddLocationUseCase: AddLocationUseCaseProtocol {
    private let repository: LocationRepositoryProtocol

    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ location: Location) async throws -> Location {
        try await repository.addLocation(location)
    }
}
