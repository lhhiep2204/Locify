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
            .interactiveDismissDisabled()
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
                }
            }
        }
    }

    private func categoryItemView(_ category: Category) -> some View {
        DSText(category.name, font: .bold(.medium))
            .lineLimit(1)
    }
}

#Preview {
    CategoryListView(ViewModelFactory.shared.makeCategoryListViewModel())
}
