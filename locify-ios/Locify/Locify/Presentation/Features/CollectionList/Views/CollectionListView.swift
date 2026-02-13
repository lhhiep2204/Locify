//
//  CollectionListView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 2/8/25.
//

import SwiftUI

struct CollectionListView: View {
    @Environment(\.appContainer) private var container
    @Environment(\.dismissSheet) private var dismissSheet

    @State private var viewModel: CollectionListViewModel

    @State private var isFetched: Bool = false

    @State private var showAddCollection: Bool = false

    @State private var collectionToUpdate: Collection?

    @State private var showDeleteAlert: Bool = false
    @State private var collectionToDelete: Collection?

    init(_ viewModel: CollectionListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if viewModel.collections.isEmpty {
                EmptyCollectionView {
                    showAddCollection = true
                }
            } else {
                listView
            }
        }
        .navigationTitle(Text(CollectionKeys.title))
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
                    showAddCollection = true
                } label: {
                    Text(CommonKeys.add)
                }
            }
        }
        .task {
            if !isFetched {
                await viewModel.fetchCollections()
                isFetched.toggle()
            }
        }
        .sheet(isPresented: $showAddCollection) {
            EditCollectionView(
                container.makeEditCollectionViewModel(),
                editMode: .add
            ) { [weak viewModel] collection in
                guard let viewModel else { return }

                Task { @MainActor in
                    await viewModel.addCollection(collection)
                }
            }
        }
        .sheet(item: $collectionToUpdate) { collection in
            EditCollectionView(
                container.makeEditCollectionViewModel(),
                editMode: .update,
                collectionToUpdate: collection
            ) { [weak viewModel] updatedCollection in
                guard let viewModel else { return }

                Task { @MainActor in
                    await viewModel.updateCollection(updatedCollection)
                }
            }
        }
        .alert(
            Text(
                String(
                    format: .localized(MessageKeys.deleteAlertTitle),
                    collectionToDelete?.name ?? .empty
                )
            ),
            isPresented: $showDeleteAlert,
            presenting: collectionToDelete
        ) { collection in
            Button(
                String.localized(CommonKeys.delete),
                role: .destructive
            ) {
                Task { @MainActor [weak viewModel] in
                    guard let viewModel else { return }

                    await viewModel.deleteCollection(collection)
                }
            }
            Button(
                String.localized(CommonKeys.cancel),
                role: .cancel
            ) {}
        } message: { _ in
            Text(MessageKeys.deleteAlertMessage)
        }
    }
}

extension CollectionListView {
    private var listView: some View {
        List {
            ForEach(viewModel.collections) { item in
                NavigationLink(
                    .locationList(collection: item)
                ) {
                    CollectionItemView(collection: item)
                        .swipeActions(edge: .trailing) {
                            deleteButtonView(item)
                            editButtonView(item)
                        }
                        .contextMenu {
                            editButtonView(item)
                            Divider()
                            deleteButtonView(item)
                        }
                }
            }
        }
        .refreshable {
            await viewModel.fetchCollections()
        }
    }

    private func editButtonView(_ collection: Collection) -> some View {
        Button {
            collectionToUpdate = collection
        } label: {
            Label {
                DSText(.localized(CommonKeys.edit))
            } icon: {
                Image.appSystemIcon(.edit)
            }
        }
    }

    private func deleteButtonView(_ collection: Collection) -> some View {
        Button {
            collectionToDelete = collection
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
        CollectionListView(AppContainer.shared.makeCollectionListViewModel())
    }
}
