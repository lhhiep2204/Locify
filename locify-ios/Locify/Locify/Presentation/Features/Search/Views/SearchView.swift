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

    @State private var textSearch: String = .empty
    @State private var searchResults: [Location] = []

    var onSelect: (Location) -> Void

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
                Task {
                    searchResults = await AppleMapService.shared.suggestions(for: textSearch)
                }
            }

            searchResultView
        }
        .padding(DSSpacing.large)
    }

    private var searchResultView: some View {
        List {
            ForEach(searchResults) { item in
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
                        let location = await AppleMapService.shared.search(for: item)
                        guard let location else { return }

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
    SearchView { _ in }
}
