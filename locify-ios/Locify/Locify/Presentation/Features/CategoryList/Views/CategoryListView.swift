//
//  CategoryListView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 2/8/25.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(\.dismiss) private var dismiss

    private var router: Router<Route>
    var categories: [Category]

    init(categories: [Category]) {
        self.categories = categories
        self.router = .init(root: .categoryList(categories: categories))
    }

    var body: some View {
        listView
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image.appSystemIcon(.close)
                    }
                }
            }
            .navigationTitle(Text(CategoryKeys.title))
            .interactiveDismissDisabled()
            .applyRouter(router)
    }
}

extension CategoryListView {
    private var listView: some View {
        List {
            ForEach(categories) { category in
                NavigationLink {
                    Text(category.name)
                } label: {
                    categoryItemView(category)
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
    CategoryListView(categories: Category.mockList)
}
