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
                    .swipeActions(edge: .trailing) {
                        deleteButtonView(item)
                        editButtonView(item)
                    }
                    .swipeActions(edge: .leading) {
                        shareButtonView(item)
                    }
                    .contextMenu {
                        editButtonView(item)
                        shareButtonView(item)
                        deleteButtonView(item)
                    }
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

    private func editButtonView(_ location: Location) -> some View {
        Button {

        } label: {
            Label {
                DSText(.localized(CommonKeys.edit))
            } icon: {
                Image.appSystemIcon(.edit)
            }
        }
    }

    private func deleteButtonView(_ location: Location) -> some View {
        Button {

        } label: {
            Label {
                DSText(.localized(CommonKeys.delete))
            } icon: {
                Image.appSystemIcon(.delete)
            }
        }
        .tint(.red)
    }

    private func shareButtonView(_ location: Location) -> some View {
        ShareLink(item: "location.infoToShare()") {
            Label {
                DSText(.localized(CommonKeys.share))
            } icon: {
                Image.appSystemIcon(.share)
            }
        }
        .tint(.blue)
    }
}

#Preview {
    if let category = Category.mockList.first {
        NavigationStack {
            LocationListView(
                ViewModelFactory.shared.makeLocationListViewModel(categoryId: category.id),
                categoryName: category.name
            )
        }
    }
}
