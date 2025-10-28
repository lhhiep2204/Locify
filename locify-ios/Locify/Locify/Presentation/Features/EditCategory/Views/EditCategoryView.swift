//
//  EditCategoryView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 20/8/25.
//

import SwiftUI

enum EditMode {
    case add, update
}

struct EditCategoryView: View {
    enum FocusField {
        case name
    }

    @FocusState private var focusField: FocusField?

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: EditCategoryViewModel

    let editMode: EditMode
    let categoryToUpdate: Category?
    let onSave: (Category) -> Void

    init(
        _ viewModel: EditCategoryViewModel,
        editMode: EditMode,
        categoryToUpdate: Category? = nil,
        onSave: @escaping (Category) -> Void
    ) {
        self.viewModel = viewModel
        self.editMode = editMode
        self.categoryToUpdate = categoryToUpdate
        self.onSave = onSave

        if let categoryToUpdate {
            viewModel.updateCategoryName(categoryToUpdate.name)
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
                            saveCategory()
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

extension EditCategoryView {
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                DSTextField(
                    text: $viewModel.name,
                    state: viewModel.errorMessage.isEmpty ? .normal : .error
                )
                .label(.localized(CategoryKeys.categoryName))
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
            Text(CategoryKeys.addCategory)
        case .update:
            Text(CategoryKeys.updateCategory)
        }
    }
}

extension EditCategoryView {
    private func saveCategory() {
        viewModel.createCategory(categoryToUpdate: categoryToUpdate) { category in
            guard let category else { return }

            onSave(category)
            dismiss()
        }
    }
}

#Preview {
    EditCategoryView(
        AppContainer.shared.makeEditCategoryViewModel(),
        editMode: .add
    ) { _ in }
}
