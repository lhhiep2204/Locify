//
//  EditCollectionView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 20/8/25.
//

import SwiftUI

enum EditMode {
    case add, update
}

struct EditCollectionView: View {
    enum FocusField {
        case name
    }

    @FocusState private var focusField: FocusField?

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: EditCollectionViewModel

    let editMode: EditMode
    let collectionToUpdate: Collection?
    let onSave: (Collection) -> Void

    init(
        _ viewModel: EditCollectionViewModel,
        editMode: EditMode,
        collectionToUpdate: Collection? = nil,
        onSave: @escaping (Collection) -> Void
    ) {
        self.viewModel = viewModel
        self.editMode = editMode
        self.collectionToUpdate = collectionToUpdate
        self.onSave = onSave

        if let collectionToUpdate {
            viewModel.updateCollectionName(collectionToUpdate.name)
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
                            focusField = .none
                            saveCollection()
                        } label: {
                            Text(CommonKeys.save)
                        }
                    }
                }
                .presentationDetents([.small])
                .interactiveDismissDisabled()
                .onAppear {
                    focusField = .name
                }
        }
    }
}

extension EditCollectionView {
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                DSTextField(
                    text: $viewModel.name,
                    state: viewModel.errorMessage.isEmpty ? .normal : .error
                )
                .label(.localized(CollectionKeys.collectionName))
                .description(viewModel.errorMessage)
                .focused($focusField, equals: .name)
            }
            .padding(DSSpacing.large)
        }
        .onChange(of: focusField) {
            switch focusField {
            case .name:
                viewModel.clearErrorState()
            case .none:
                break
            }
        }
        .onTapGesture {
            focusField = .none
        }
    }

    private var navigationTitle: Text {
        switch editMode {
        case .add:
            Text(CollectionKeys.addCollection)
        case .update:
            Text(CollectionKeys.updateCollection)
        }
    }
}

extension EditCollectionView {
    private func saveCollection() {
        viewModel.createCollection(collectionToUpdate: collectionToUpdate) { collection in
            guard let collection else { return }

            onSave(collection)
            dismiss()
        }
    }
}

#Preview {
    EditCollectionView(
        AppContainer.shared.makeEditCollectionViewModel(),
        editMode: .add
    ) { _ in }
}
