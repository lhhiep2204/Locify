//
//  SwiftDataContainer.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/2/26.
//

import Foundation
import SwiftData

/// Singleton container for SwiftData setup. Used ONLY in the Data layer.
/// Presentation/Domain layers should never access this directly.
final class SwiftDataContainer {
    static let shared = SwiftDataContainer()

    let modelContainer: ModelContainer
    let mainContext: ModelContext

    private init() {
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

            mainContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    /// Create a SwiftDataManager from the main context.
    func makeMainManager() -> SwiftDataManaging {
        SwiftDataManager(modelContext: mainContext)
    }

    /// Create a new background context for background operations.
    func makeBackgroundContext() -> ModelContext {
        ModelContext(modelContainer)
    }

    /// Create a SwiftDataManager for background operations.
    func makeBackgroundManager() -> SwiftDataManaging {
        SwiftDataManager(modelContext: makeBackgroundContext())
    }
}
