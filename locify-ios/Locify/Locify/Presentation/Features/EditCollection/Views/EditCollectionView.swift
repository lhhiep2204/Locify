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

    let onSave: (Collection) -> Void

    init(
        _ viewModel: EditCollectionViewModel,
        onSave: @escaping (Collection) -> Void
    ) {
        self.viewModel = viewModel
        self.onSave = onSave
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
        switch viewModel.mode {
        case .create:
            Text(CollectionKeys.addCollection)
        case .update:
            Text(CollectionKeys.updateCollection)
        }
    }
}

extension EditCollectionView {
    private func saveCollection() {
        viewModel.save { collection in
            guard let collection else { return }

            onSave(collection)
            dismiss()
        }
    }
}

#Preview {
    EditCollectionView(
        AppContainer().makeEditCollectionViewModel(.create)
    ) { _ in }
}
