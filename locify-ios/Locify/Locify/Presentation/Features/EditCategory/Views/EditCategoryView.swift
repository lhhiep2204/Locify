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

    let editMode: EditMode
    let categoryToUpdate: Category?
    let onSave: (Category) -> Void

    init(
        editMode: EditMode,
        categoryToUpdate: Category? = nil,
        onSave: @escaping (Category) -> Void
    ) {
        self.editMode = editMode
        self.categoryToUpdate = categoryToUpdate
        self.onSave = onSave
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
                .interactiveDismissDisabled()
        }
    }
}

extension EditCategoryView {
    private var contentView: some View {
        Text(CategoryKeys.title)
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
        onSave(.mock)
        dismiss()
    }
}

#Preview {
    EditCategoryView(editMode: .add, onSave: { _ in })
}
