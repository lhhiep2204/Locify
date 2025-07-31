//
//  LocationDetailView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import SwiftUI

struct LocationDetailView: View {
    @Binding var location: Location?
    let relatedLocations: [Location]

    var body: some View {
        if let location {
            VStack(alignment: .leading) {
                headerView(location: location)
                    .padding(.horizontal)

                List {
                    relatedLocationSection
                }
                .scrollContentBackground(.hidden)
            }
        } else {
            DSText("Please select a location")
        }
    }
}

extension LocationDetailView {
    private func headerView(location: Location) -> some View {
        Group {
            DSText(
                location.name,
                font: .bold(.large)
            )
            .lineLimit(1)

            DSText(
                location.address,
                font: .medium(.medium)
            )
            .lineLimit(2)
        }
    }

    private var relatedLocationSection: some View {
        Section(
            header: DSText(
                "Related Locations",
                font: .regular(.small),
                color: .appColor(.textSecondary)
            )
        ) {
            ForEach(relatedLocations) { item in
                VStack(alignment: .leading) {
                    DSText(
                        item.name,
                        font: .bold(.medium)
                    )
                    .lineLimit(1)

                    DSText(
                        item.address,
                        font: .medium(.small)
                    )
                    .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    location = item
                }
            }
        }
    }
}

#Preview {
    LocationDetailView(
        location: .constant(.mockList.first),
        relatedLocations: Location.mockList
    )
}
