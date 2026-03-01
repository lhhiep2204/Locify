//
//  SwiftDataContainer.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/2/26.
//

import SwiftData

/// Singleton container for SwiftData setup. Used ONLY in the Data layer.
/// Presentation/Domain layers should never access this directly.
final class SwiftDataContainer {
    private let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema(
                [
                    CollectionLocal.self,
                    LocationLocal.self
                ]
            )

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    /// Create a SwiftDataManager from the main context.
    func makeMainManager() -> SwiftDataManagerProtocol {
        SwiftDataManager(modelContext: ModelContext(modelContainer))
    }

    /// Create a SwiftDataManager for background operations.
    func makeBackgroundManager() -> SwiftDataManagerProtocol {
        SwiftDataManager(modelContext: ModelContext(modelContainer))
    }
}
