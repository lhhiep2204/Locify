//
//  EmptyLocationView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/2/26.
//

import SwiftUI

struct EmptyLocationView: View {
    let collectionName: String
    let onAddLocation: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label {
                DSText("No Locations", font: .bold(.large))
            } icon: {
                Image.appSystemIcon(.emptyList)
            }
        } description: {
            DSText(
                "Add your first location to \"\(collectionName)\"",
                font: .regular(.small)
            )
        } actions: {
            Button(
                String.localized(CommonKeys.add)
            ) {
                onAddLocation()
            }
            .buttonStyle(.glass)
        }
    }
}

#Preview {
    EmptyLocationView(collectionName: "Food") {
        Logger.info("Add location tapped")
    }
}
