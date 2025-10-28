//
//  CategoryListView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 2/8/25.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(\.appContainer) private var container
    @Environment(\.dismissSheet) private var dismissSheet

    @State private var viewModel: CategoryListViewModel

    @State private var isFetched: Bool = false

    @State private var showAddCategory: Bool = false

    @State private var categoryToUpdate: Category?

    @State private var showDeleteAlert: Bool = false
    @State private var categoryToDelete: Category?

    init(_ viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        listView
            .navigationTitle(Text(CategoryKeys.title))
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
                        showAddCategory = true
                    } label: {
                        Text(CommonKeys.add)
                    }
                }
            }
            .task {
                if !isFetched {
                    await viewModel.fetchCategories()
                    isFetched.toggle()
                }
            }
            .sheet(isPresented: $showAddCategory) {
                EditCategoryView(
                    container.makeEditCategoryViewModel(),
                    editMode: .add
                ) { category in
                    Task {
                        await viewModel.addCategory(category)
                    }
                }
            }
            .sheet(item: $categoryToUpdate) { category in
                EditCategoryView(
                    container.makeEditCategoryViewModel(),
                    editMode: .update,
                    categoryToUpdate: category
                ) { updatedCategory in
                    Task {
                        await viewModel.updateCategory(updatedCategory)
                    }
                }
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
                Text(MessageKeys.deleteAlertMessage)
            }
    }
}

extension CategoryListView {
    private var listView: some View {
        List {
            ForEach(viewModel.categories) { item in
                NavigationLink(
                    .locationList(category: item)
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
        .refreshable {
            await viewModel.fetchCategories()
        }
    }

    private func categoryItemView(_ category: Category) -> some View {
        HStack(spacing: DSSpacing.small) {
            Image.appSystemIcon(.folder)
            DSText(category.name, font: .medium(.medium))
                .lineLimit(1)
        }
    }

    private func editButtonView(_ category: Category) -> some View {
        Button {
            categoryToUpdate = category
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
        CategoryListView(AppContainer.shared.makeCategoryListViewModel())
    }
}
