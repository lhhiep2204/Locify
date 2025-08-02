//
//  LocationListView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 2/8/25.
//

import SwiftUI

struct LocationListView: View {
    @Environment(\.dismissSheet) private var dismissSheet

    var locations: [Location]

    var body: some View {
        listView
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismissSheet()
                    } label: {
                        Image.appSystemIcon(.close)
                    }
                }
            }
            .navigationTitle(Text(LocationKeys.title))
            .interactiveDismissDisabled()
    }
}

extension LocationListView {
    private var listView: some View {
        List {
            ForEach(locations) { item in
                locationItemView(item)
            }
        }
    }

    private func locationItemView(_ location: Location) -> some View {
        VStack(alignment: .leading) {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            dismissSheet()
        }
    }
}

#Preview {
    LocationListView(locations: Location.mockList)
}
