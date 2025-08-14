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

    init(_ viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        listView
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismissSheet()
                    } label: {
                        Image.appSystemIcon(.close)
                    }
                }
            }
            .navigationTitle(Text(CategoryKeys.title))
            .task {
                await viewModel.fetchCategories()
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
                        .swipeActions(edge: .leading) {
                            shareButtonView(item)
                        }
                        .contextMenu {
                            editButtonView(item)
                            shareButtonView(item)
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

        } label: {
            Label {
                DSText(.localized(CommonKeys.delete))
            } icon: {
                Image.appSystemIcon(.delete)
            }
        }
        .tint(.red)
    }
    
    private func shareButtonView(_ category: Category) -> some View {
        ShareLink(item: "location.infoToShare()") {
            Label {
                DSText(.localized(CommonKeys.share))
            } icon: {
                Image.appSystemIcon(.share)
            }
        }
        .tint(.blue)
    }
}

#Preview {
    NavigationStack {
        CategoryListView(ViewModelFactory.shared.makeCategoryListViewModel())
    }
}
