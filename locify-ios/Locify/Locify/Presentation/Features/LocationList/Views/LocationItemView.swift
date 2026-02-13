//
//  LocationItemView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 14/2/26.
//

import SwiftUI

struct LocationItemView: View {
    let location: Location

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xSmall) {
            DSText(
                location.displayName.isEmpty ? location.name : location.displayName,
                font: .medium(.medium)
            )
            .lineLimit(1)

            DSText(
                location.address,
                font: .regular(.small)
            )
            .lineLimit(2)

            DSText(
                location.createdAt.toString(style: .dayMonthYear),
                font: .regular(.custom(11))
            )
        }
    }
}

#Preview {
    LocationItemView(location: .mock)
}
