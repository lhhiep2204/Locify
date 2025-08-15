//
//  CategoryListView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 2/8/25.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(\.dismissSheet) private var dismissSheet
    @Environment(\.viewModelFactory) private var factory

    @State private var viewModel: CategoryListViewModel

    @State private var showDeleteAlert: Bool = false
    @State private var categoryToDelete: Category?

    init(_ viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        listView
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

                    } label: {
                        Text(String.localized(CommonKeys.add))
                    }
                }
            }
            .navigationTitle(Text(CategoryKeys.title))
            .task {
                await viewModel.fetchCategories()
            }
            .alert(
                Text(
                    String(
                        format: .localized(MessageKeys.deleteAlertTitle),
                        categoryToDelete?.name ?? ""
                    )
                ),
                isPresented: $showDeleteAlert,
                presenting: categoryToDelete
            ) { category in
                Button(
                    String.localized(CommonKeys.delete),
                    role: .destructive
                ) {
                    Task {
                        await viewModel.deleteCategory(category)
                    }
                }
                Button(
                    String.localized(CommonKeys.cancel),
                    role: .cancel
                ) {}
            } message: { _ in
                Text(String.localized(MessageKeys.deleteAlertMessage))
            }
    }
}

extension CategoryListView {
    private var listView: some View {
        List {
            ForEach(viewModel.categories) { item in
                NavigationLink(
                    .locationList(
                        categoryId: item.id,
                        categoryName: item.name
                    )
                ) {
                    categoryItemView(item)
                        .swipeActions(edge: .trailing) {
                            deleteButtonView(item)
                            editButtonView(item)
                        }
                        .contextMenu {
                            editButtonView(item)
                            deleteButtonView(item)
                        }
                }
            }
        }
    }

    private func categoryItemView(_ category: Category) -> some View {
        DSText(category.name, font: .bold(.medium))
            .lineLimit(1)
    }

    private func editButtonView(_ category: Category) -> some View {
        Button {

        } label: {
            Label {
                DSText(.localized(CommonKeys.edit))
            } icon: {
                Image.appSystemIcon(.edit)
            }
        }
    }

    private func deleteButtonView(_ category: Category) -> some View {
        Button {
            categoryToDelete = category
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
        CategoryListView(ViewModelFactory.shared.makeCategoryListViewModel())
    }
}
