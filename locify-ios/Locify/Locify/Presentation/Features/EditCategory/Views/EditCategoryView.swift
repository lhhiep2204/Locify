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

    @State private var name: String

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

        if let categoryToUpdate {
            _name = State(initialValue: categoryToUpdate.name)
        } else {
            _name = State(initialValue: .empty)
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
                DSTextField(text: $name)
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
        var category: Category {
            if let categoryToUpdate {
                var category = categoryToUpdate
                category.name = name
                return category
            } else {
                let category = Category(name: name)
                return category
            }
        }

        onSave(category)
        dismiss()
    }
}

#Preview {
    EditCategoryView(editMode: .add, onSave: { _ in })
}
