//
//  LocifyApp.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 26/6/25.
//

import SwiftUI

@main
struct LocifyApp: App {
    private var router: Router<Route> = .init(root: .home)

    var body: some Scene {
        WindowGroup {
            RouterView(router)
        }
    }
}
