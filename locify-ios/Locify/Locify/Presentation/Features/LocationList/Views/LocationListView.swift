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

    @State private var showAddLocation: Bool = false

    @State private var showUpdateLocation: Bool = false
    @State private var locationToUpdate: Location?

    @State private var showDeleteAlert: Bool = false
    @State private var locationToDelete: Location?

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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismissSheet()
                    } label: {
                        Image.appSystemIcon(.close)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddLocation = true
                    } label: {
                        Text(String.localized(CommonKeys.add))
                    }
                }
            }
            .navigationTitle(Text(categoryName))
            .task {
                await viewModel.fetchLocations()
            }
            .sheet(isPresented: $showAddLocation) {
                EditLocationView(editMode: .add) { location in
                    Task {
                        await viewModel.addLocation(location)
                    }
                }
            }
            .sheet(isPresented: $showUpdateLocation) {
                EditLocationView(
                    editMode: .update,
                    locationToUpdate: locationToUpdate
                ) { location in
                    Task {
                        await viewModel.updateLocation(location)
                    }
                }
            }
            .alert(
                Text(
                    String(
                        format: MessageKeys.deleteAlertTitle.rawValue, locationToDelete?.name ?? ""
                    )
                ),
                isPresented: $showDeleteAlert,
                presenting: locationToDelete
            ) { location in
                Button(
                    String.localized(CommonKeys.delete),
                    role: .destructive
                ) {
                    Task {
                        await viewModel.deleteLocation(location)
                    }
                }
                Button(
                    String.localized(CommonKeys.cancel),
                    role: .cancel
                ) {}
            } message: { _ in
                Text(MessageKeys.deleteAlertMessage.rawValue)
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
        .refreshable {
            await viewModel.fetchLocations()
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
            locationToDelete = location
            showUpdateLocation = true
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
            locationToDelete = location
            showDeleteAlert = true
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
