//
//  DeleteLocationUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 14/8/25.
//

import Foundation

protocol DeleteLocationUseCaseProtocol {
    func execute(_ location: Location) async throws -> Location
}

struct DeleteLocationUseCase: DeleteLocationUseCaseProtocol {
    private let repository: LocationRepositoryProtocol

    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ location: Location) async throws -> Location {
        try await repository.deleteLocation(location)
    }
}
