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

    let onSave: (Location) -> Void

    init(
        _ viewModel: EditLocationViewModel,
        collection: Collection? = nil,
        onSave: @escaping (Location) -> Void
    ) {
        self.viewModel = viewModel
        self.onSave = onSave

        if let collection = viewModel.collection {
            _collectionName = State(initialValue: collection.name)
        } else {
            _collectionName = State(initialValue: .empty)
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
                            EditCollectionView(EditCollectionViewModel(mode: .create)) { collection in
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
                if case .create = viewModel.mode {
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
        switch viewModel.mode {
        case .create:
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
        var location: Location? {
            if case let .update(location) = viewModel.mode {
                location
            } else if let location = searchedLocation {
                location
            } else {
                nil
            }
        }

        if let location {
            MapSnapshotView(
                latitude: location.latitude,
                longitude: location.longitude,
                category: location.category
            )
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
        viewModel.save { location in
            guard let location else { return }

            onSave(location)
            dismiss()
        }
    }
}

#Preview {
    EditLocationView(
        AppContainer().makeEditLocationViewModel(.create, collection: nil)
    ) { _ in }
}
