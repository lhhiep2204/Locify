//
//  LocationListView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 2/8/25.
//

import SwiftUI

struct LocationListView: View {
    @Environment(\.appContainer) private var container
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dismissSheet) private var dismissSheet
    @Environment(\.selectLocation) private var selectLocation

    @State private var viewModel: LocationListViewModel

    @State private var isFetched: Bool = false

    @State private var showAddLocation: Bool = false

    @State private var locationToSave: Location?

    @State private var showDeleteAlert: Bool = false
    @State private var locationToDelete: Location?

    init(_ viewModel: LocationListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if viewModel.locations.isEmpty {
                EmptyLocationView(collectionName: viewModel.collection.name) {
                    showAddLocation = true
                }
            } else {
                listView
            }
        }
        .navigationTitle(Text(viewModel.collection.name))
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
                    Text(CommonKeys.add)
                }
            }
        }
        .task {
            if !isFetched {
                await viewModel.fetchLocations()
                isFetched.toggle()
            }
        }
        .sheet(isPresented: $showAddLocation) {
            EditLocationView(
                container.makeEditLocationViewModel(),
                editMode: .add,
                collection: viewModel.collection
            ) { [weak viewModel] location in
                guard let viewModel else { return }

                Task { @MainActor in
                    await viewModel.addLocation(location)
                }
            }
        }
        .sheet(item: $locationToSave) { location in
            EditLocationView(
                container.makeEditLocationViewModel(),
                editMode: .update,
                collection: viewModel.collection,
                locationToSave: location
            ) { [weak viewModel] updatedLocation in

                guard let viewModel else { return }
                Task { @MainActor in
                    await viewModel.updateLocation(updatedLocation)
                }
            }
        }
        .alert(
            Text(
                String(
                    format: MessageKeys.deleteAlertTitle.rawValue, locationToDelete?.name ?? .empty
                )
            ),
            isPresented: $showDeleteAlert,
            presenting: locationToDelete
        ) { location in
            Button(
                String.localized(CommonKeys.delete),
                role: .destructive
            ) {
                Task { @MainActor [weak viewModel] in
                    guard let viewModel else { return }

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
                        shareButtonView(item)
                        editButtonView(item)
                        Divider()
                        deleteButtonView(item)
                    }
            }
        }
        .refreshable {
            await viewModel.fetchLocations()
        }
    }

    private func locationItemView(_ location: Location) -> some View {
        LocationItemView(location: location)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                selectLocation(
                    viewModel.collection,
                    location.id,
                    viewModel.locations
                )
            }
    }

    private func shareButtonView(_ location: Location) -> some View {
        ShareLink(item: location.shareMessage) {
            Label {
                DSText(.localized(CommonKeys.share))
            } icon: {
                Image.appSystemIcon(.share)
            }
        }
        .tint(.blue)
    }

    private func editButtonView(_ location: Location) -> some View {
        Button {
            locationToSave = location
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
}

#Preview {
    NavigationStack {
        LocationListView(
            AppContainer.shared.makeLocationListViewModel(collection: .mock)
        )
    }
}
