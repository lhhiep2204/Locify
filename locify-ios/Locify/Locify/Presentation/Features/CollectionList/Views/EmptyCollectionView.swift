//
//  EmptyCollectionView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/2/26.
//

import SwiftUI

struct EmptyCollectionView: View {
    let onAddLocation: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label {
                DSText("No Collections", font: .bold(.large))
            } icon: {
                Image.appSystemIcon(.emptyList)
            }
        } description: {
            DSText(
                "Add your first collection to organize your locations",
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
    EmptyCollectionView {
        Logger.info("Add collection tapped")
    }
}
