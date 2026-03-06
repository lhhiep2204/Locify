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
        HStack(spacing: DSSpacing.medium) {
            ZStack {
                RoundedRectangle(cornerRadius: DSRadius.xxLarge)
                    .fill(.gray.opacity(0.15))
                    .frame(width: DSSize.huge, height: DSSize.huge)

                Image.appSystemIcon(.folder)
            }

            VStack(alignment: .leading, spacing: DSSpacing.xSmall) {
                DSText(collection.name, font: .medium(.medium))
                    .lineLimit(1)

                DSText(
                    collection.createdAt.toString(style: .dayMonthYear),
                    systemFont: .caption2
                )
            }
        }
    }
}

#Preview {
    CollectionItemView(collection: .mock)
}
