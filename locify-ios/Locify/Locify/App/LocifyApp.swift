//
//  LocifyApp.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 26/6/25.
//

import SwiftUI
import SwiftData

@main
struct LocifyApp: App {
    private var router: Router<Route> = .init(root: .home)

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RouterView(router)
        }
        .modelContainer(sharedModelContainer)
    }
}
