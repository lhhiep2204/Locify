//
//  CollectionItemView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 14/2/26.
//

import SwiftUI

struct CollectionItemView: View {
    let collection: Collection

    var body: some View {
        HStack(spacing: DSSpacing.small) {
            Image.appSystemIcon(.folder)
            DSText(collection.name, font: .medium(.medium))
                .lineLimit(1)
        }
    }
}

#Preview {
    CollectionItemView(collection: .mock)
}
