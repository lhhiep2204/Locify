//
//  SearchView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 30/9/25.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss

    @FocusState private var editing: Bool

    @State private var viewModel: SearchViewModel
    @State private var textSearch: String = .empty

    private let onSelect: (Location) -> Void

    init(
        _ viewModel: SearchViewModel,
        onSelect: @escaping (Location) -> Void
    ) {
        self.viewModel = viewModel
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle(Text(CommonKeys.search))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image.appSystemIcon(.close)
                        }
                    }
                }
                .onAppear {
                    editing = true
                }
        }
    }
}

extension SearchView {
    private var contentView: some View {
        VStack(alignment: .leading, spacing: DSSpacing.medium) {
            DSTextField(
                .constant(.localized(LocationKeys.searchLocation)),
                text: $textSearch
            )
            .image(.appSystemIcon(.search))
            .focused($editing)
            .onChange(of: textSearch) {
                Task { await viewModel.search(query: textSearch) }
            }

            searchResultView
        }
        .padding(DSSpacing.large)
    }

    private var searchResultView: some View {
        List {
            ForEach(viewModel.searchResults) { item in
                VStack(alignment: .leading, spacing: DSSpacing.xSmall) {
                    DSText(
                        item.name,
                        font: .medium(.medium)
                    )
                    .lineLimit(1)

                    DSText(
                        item.address,
                        font: .regular(.small)
                    )
                    .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    Task {
                        guard let location = await viewModel.selectLocation(item) else { return }

                        onSelect(location)
                        dismiss()
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    SearchView(AppContainer().makeSearchViewModel()) { _ in }
}
