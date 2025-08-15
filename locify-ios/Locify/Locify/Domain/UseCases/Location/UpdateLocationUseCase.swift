//
//  UpdateLocationUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 14/8/25.
//

import Foundation

protocol UpdateLocationUseCaseProtocol {
    func execute(_ location: Location) async throws -> Location
}

struct UpdateLocationUseCase: UpdateLocationUseCaseProtocol {
    private let repository: LocationRepositoryProtocol

    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ location: Location) async throws -> Location {
        try await repository.updateLocation(location)
    }
}
