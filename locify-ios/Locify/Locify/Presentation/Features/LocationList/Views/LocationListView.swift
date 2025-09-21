//
//  LocationListView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 2/8/25.
//

import SwiftUI

struct LocationListView: View {
    @Environment(\.viewModelFactory) private var factory
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dismissSheet) private var dismissSheet
    @Environment(\.selectLocation) private var selectLocation

    @State private var viewModel: LocationListViewModel

    @State private var isFetched: Bool = false

    @State private var showAddLocation: Bool = false

    @State private var locationToUpdate: Location?

    @State private var showDeleteAlert: Bool = false
    @State private var locationToDelete: Location?

    init(_ viewModel: LocationListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        listView
            .navigationTitle(Text(viewModel.category.name))
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
                    factory.makeEditLocationViewModel(),
                    editMode: .add,
                    category: viewModel.category
                ) { location in
                    Task {
                        await viewModel.addLocation(location)
                    }
                }
            }
            .sheet(item: $locationToUpdate) { location in
                EditLocationView(
                    factory.makeEditLocationViewModel(),
                    editMode: .update,
                    category: viewModel.category,
                    locationToUpdate: location
                ) { updatedLocation in
                    Task {
                        await viewModel.updateLocation(updatedLocation)
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
        VStack(alignment: .leading, spacing: DSSpacing.xSmall) {
            DSText(
                location.displayName,
                font: .medium(.medium)
            )
            .lineLimit(1)

            DSText(
                location.address,
                font: .regular(.small)
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
            locationToUpdate = location
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
                ViewModelFactory.shared.makeLocationListViewModel(category: category)
            )
        }
    }
}
