//
//  EditLocationView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 20/8/25.
//

import SwiftUI

struct EditLocationView: View {
    enum FocusField {
        case displayName, notes
    }

    @Environment(\.dismiss) private var dismiss

    @FocusState private var focusField: FocusField?

    @State private var viewModel: EditLocationViewModel

    @State private var textSearch: String = .empty
    @State private var searchedLocation: Location?
    @State private var collectionName: String

    @State private var showSearchView: Bool = false
    @State private var showCollectionList: Bool = false
    @State private var showAddCollection: Bool = false
    @State private var showErrorAlert: Bool = false

    let editMode: EditMode
    let locationToSave: Location?
    let onSave: (Location) -> Void

    init(
        _ viewModel: EditLocationViewModel,
        editMode: EditMode,
        collection: Collection? = nil,
        locationToSave: Location? = nil,
        onSave: @escaping (Location) -> Void
    ) {
        self.viewModel = viewModel
        self.editMode = editMode
        self.locationToSave = locationToSave
        self.onSave = onSave

        viewModel.collection = collection

        if let collection {
            _collectionName = State(initialValue: collection.name)
        } else {
            _collectionName = State(initialValue: .empty)
        }

        if let locationToSave {
            viewModel.placeId = locationToSave.placeId
            viewModel.displayName = locationToSave.displayName
            viewModel.name = locationToSave.name
            viewModel.address = locationToSave.address
            viewModel.latitude = String(locationToSave.latitude)
            viewModel.longitude = String(locationToSave.longitude)
            viewModel.notes = locationToSave.notes ?? .empty
        }
    }

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image.appSystemIcon(.close)
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            saveLocation()
                        } label: {
                            Text(CommonKeys.save)
                        }
                    }
                }
                .interactiveDismissDisabled()
                .task {
                    await viewModel.fetchCollections()
                }
                .onChange(of: viewModel.collection) {
                    collectionName = viewModel.collection?.name ?? .empty
                }
                .sheet(isPresented: $showSearchView) {
                    RouterView(
                        Router<Route>(
                            root: .search { location in
                                searchedLocation = location
                                viewModel.selectSearchedLocation(location)
                            }
                        )
                    )
                }
                .sheet(isPresented: $showCollectionList) {
                    selectCollectionView
                        .presentationDetents([.medium])
                        .sheet(isPresented: $showAddCollection) {
                            EditCollectionView(
                                EditCollectionViewModel(),
                                editMode: .add
                            ) { collection in
                                Task {
                                    await viewModel.addCollection(collection)
                                }
                            }
                        }
                }
                .alert(
                    viewModel.errorMessage,
                    isPresented: $showErrorAlert
                ) {
                    Button(CommonKeys.close) {
                        viewModel.clearErrorState()
                    }
                }
        }
    }
}

extension EditLocationView {
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.medium) {
                if locationToSave == nil {
                    searchView
                }
                collectionView
                mapView
                locationInfoView
            }
            .padding(DSSpacing.large)
        }
        .onTapGesture {
            focusField = nil
        }
    }

    private var navigationTitle: Text {
        switch editMode {
        case .add:
            Text(LocationKeys.addLocation)
        case .update:
            Text(LocationKeys.updateLocation)
        }
    }

    private var searchView: some View {
        Group {
            DSTextField(
                .constant(.localized(LocationKeys.searchLocation)),
                text: $textSearch
            )
            .image(.appSystemIcon(.search))
            .disabled(true)
            .onTapGesture {
                showSearchView = true
            }

            Divider()
                .background(.backgroundSecondaryInverted)
                .padding(.vertical, DSSpacing.small)
        }
    }

    @ViewBuilder
    private var mapView: some View {
        if let location = locationToSave ?? searchedLocation {
            MapView(
                selectedLocation: .constant(location),
                locations: [location]
            ) { _ in }
                .allowsHitTesting(false)
                .aspectRatio(2/1, contentMode: .fit)
                .cornerRadius(DSRadius.xxLarge)
        }
    }

    private var collectionView: some View {
        Group {
            DSTextField(
                .constant(.localized(CollectionKeys.selectCollection)),
                text: $collectionName
            )
            .label(.localized(CollectionKeys.collection))
            .image(.appSystemIcon(.folder))
            .trailingImage(.appSystemIcon(.chevronDown))
            .disabled(true)
            .onTapGesture {
                showCollectionList = true
            }

            Divider()
                .background(.backgroundSecondaryInverted)
                .padding(.vertical, DSSpacing.small)
        }
    }

    private var locationInfoView: some View {
        Group {
            DSTextField(text: $viewModel.displayName)
                .label(.localized(LocationKeys.displayName))
                .focused($focusField, equals: .displayName)
                .onSubmit {
                    focusField = .notes
                }
            DSTextField(text: $viewModel.name)
                .label(.localized(LocationKeys.name))
                .multiline()
                .enabled(false)
            DSTextField(text: $viewModel.address)
                .label(.localized(LocationKeys.address))
                .multiline()
                .enabled(false)
            HStack {
                DSTextField(text: $viewModel.latitude)
                    .label(.localized(LocationKeys.latitude))
                    .enabled(false)
                DSTextField(text: $viewModel.longitude)
                    .label(.localized(LocationKeys.longitude))
                    .enabled(false)
            }
            DSTextField(text: $viewModel.notes)
                .label(.localized(LocationKeys.notes))
                .multiline()
                .focused($focusField, equals: .notes)
        }
    }

    private var selectCollectionView: some View {
        NavigationStack {
            Group {
                if viewModel.collections.isEmpty {
                    EmptyCollectionView {
                        showAddCollection = true
                    }
                } else {
                    List {
                        ForEach(viewModel.collections) { item in
                            DSText(item.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.collection = item
                                    showCollectionList = false
                                }
                        }
                    }
                }
            }
            .navigationTitle(Text(CollectionKeys.title))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showCollectionList = false
                    } label: {
                        Image.appSystemIcon(.close)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddCollection = true
                    } label: {
                        Text(CommonKeys.add)
                    }
                }
            }
        }
    }
}

extension EditLocationView {
    private func saveLocation() {
        func handleLocationResult(_ location: Location?) {
            if let location {
                onSave(location)
                dismiss()
            } else {
                showErrorAlert = true
            }
        }

        switch editMode {
        case .add:
            viewModel.createLocation { location in
                handleLocationResult(location)
            }
        case .update:
            viewModel.updateLocation(locationToUpdate: locationToSave) { location in
                handleLocationResult(location)
            }
        }
    }
}

#Preview {
    EditLocationView(
        AppContainer.shared.makeEditLocationViewModel(),
        editMode: .add,
        locationToSave: .mock
    ) { _ in }
}
