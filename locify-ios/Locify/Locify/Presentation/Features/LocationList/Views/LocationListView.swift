//
//  LocationListView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 2/8/25.
//

import SwiftUI

struct LocationListView: View {
    @Environment(\.dismissSheet) private var dismissSheet
    @Environment(\.selectLocation) private var selectLocation

    @State private var viewModel: LocationListViewModel
    private let categoryName: String

    init(
        _ viewModel: LocationListViewModel,
        categoryName: String
    ) {
        self.viewModel = viewModel
        self.categoryName = categoryName
    }

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
            .navigationTitle(Text(categoryName))
            .interactiveDismissDisabled()
            .task {
                await viewModel.fetchLocations()
            }
    }
}

extension LocationListView {
    private var listView: some View {
        List {
            ForEach(viewModel.locations) { item in
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
            selectLocation(location.id, viewModel.locations)
        }
    }
}

#Preview {
    LocationListView(
        ViewModelFactory.shared.makeLocationListViewModel(categoryId: UUID()),
        categoryName: "Category Name"
    )
}
