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
    @Environment(\.dismiss) private var dismiss

    @FocusState private var editing

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
            viewModel.name = categoryToUpdate.name
        }
    }

    var body: some View {
        NavigationStack {
            contentView
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
                            saveCategory()
                        } label: {
                            Text(String.localized(CommonKeys.save))
                        }
                    }
                }
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .presentationDetents([.fraction(0.25)])
                .interactiveDismissDisabled()
        }
    }
}

extension EditCategoryView {
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                DSTextField(text: $viewModel.name)
                    .label(.localized(CategoryKeys.categoryName))
                    .focused($editing)
            }
            .padding(DSSpacing.large)
        }
        .onTapGesture {
            editing = false
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
            onSave(category)
            dismiss()
        }
    }
}

#Preview {
    EditCategoryView(
        ViewModelFactory.shared.makeEditCategoryViewModel(),
        editMode: .add
    ) { _ in }
}
