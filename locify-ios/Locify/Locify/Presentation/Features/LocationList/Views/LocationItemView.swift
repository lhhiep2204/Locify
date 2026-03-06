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
        HStack(spacing: DSSpacing.medium) {
            ZStack {
                let style = POIStyleHelper.style(for: location.category)

                RoundedRectangle(cornerRadius: DSRadius.xxLarge)
                    .fill(style.color.opacity(0.15))
                    .frame(width: DSSize.huge, height: DSSize.huge)

                Image(systemName: style.icon)
            }

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
                    systemFont: .caption2
                )
            }
        }
    }
}

#Preview {
    LocationItemView(location: .mock)
}
