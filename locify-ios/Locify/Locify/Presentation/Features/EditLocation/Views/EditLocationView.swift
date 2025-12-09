//
//  EditLocationView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 20/8/25.
//

import SwiftUI

struct EditLocationView: View {
    enum FocusField {
        case displayName, notes
    }

    @Environment(\.dismiss) private var dismiss

    @FocusState private var focusField: FocusField?

    @State private var viewModel: EditLocationViewModel

    @State private var textSearch: String = .empty
    @State private var categoryName: String

    @State private var showSearchView: Bool = false
    @State private var showCategoryList: Bool = false
    @State private var showAddCategory: Bool = false
    @State private var showErrorAlert: Bool = false

    let editMode: EditMode
    let locationToSave: Location?
    let onSave: (Location) -> Void

    init(
        _ viewModel: EditLocationViewModel,
        editMode: EditMode,
        category: Category? = nil,
        locationToSave: Location? = nil,
        onSave: @escaping (Location) -> Void
    ) {
        self.viewModel = viewModel
        self.editMode = editMode
        self.locationToSave = locationToSave
        self.onSave = onSave

        viewModel.category = category

        if let category {
            _categoryName = State(initialValue: category.name)
        } else {
            _categoryName = State(initialValue: .empty)
        }

        if let locationToSave {
            viewModel.placeId = locationToSave.placeId
            viewModel.displayName = locationToSave.displayName
            viewModel.name = locationToSave.name
            viewModel.address = locationToSave.address
            viewModel.latitude = String(locationToSave.latitude)
            viewModel.longitude = String(locationToSave.longitude)
            viewModel.notes = locationToSave.notes ?? .empty
        }
    }

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
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
                            saveLocation()
                        } label: {
                            Text(CommonKeys.save)
                        }
                    }
                }
                .interactiveDismissDisabled()
                .task {
                    await viewModel.fetchCategories()
                }
                .onChange(of: viewModel.category) {
                    categoryName = viewModel.category?.name ?? .empty
                }
                .sheet(isPresented: $showSearchView) {
                    RouterView(
                        Router<Route>(
                            root: .search { location in
                                viewModel.selectSearchedLocation(location)
                            }
                        )
                    )
                }
                .sheet(isPresented: $showCategoryList) {
                    selectCategoryView
                        .presentationDetents([.medium])
                        .sheet(isPresented: $showAddCategory) {
                            EditCategoryView(
                                EditCategoryViewModel(),
                                editMode: .add
                            ) { category in
                                Task {
                                    await viewModel.addCategory(category)
                                }
                            }
                        }
                }
                .alert(
                    viewModel.errorMessage,
                    isPresented: $showErrorAlert
                ) {
                    Button(CommonKeys.close) {
                        viewModel.clearErrorState()
                    }
                }
        }
    }
}

extension EditLocationView {
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.medium) {
                if locationToSave == nil {
                    searchView
                }
                categoryView
                locationInfoView
            }
            .padding(DSSpacing.large)
        }
        .onTapGesture {
            focusField = nil
        }
    }

    private var navigationTitle: Text {
        switch editMode {
        case .add:
            Text(LocationKeys.addLocation)
        case .update:
            Text(LocationKeys.updateLocation)
        }
    }

    private var searchView: some View {
        Group {
            DSTextField(
                .constant(.localized(LocationKeys.searchLocation)),
                text: $textSearch
            )
            .image(.appSystemIcon(.search))
            .disabled(true)
            .onTapGesture {
                showSearchView = true
            }

            Divider()
                .padding(.vertical, DSSpacing.small)
        }
    }

    private var categoryView: some View {
        Group {
            DSTextField(
                .constant(.localized(CategoryKeys.selectCategory)),
                text: $categoryName
            )
            .label(.localized(CategoryKeys.category))
            .image(.appSystemIcon(.folder))
            .trailingImage(.appSystemIcon(.chevronDown))
            .disabled(true)
            .onTapGesture {
                showCategoryList = true
            }

            Divider()
                .padding(.vertical, DSSpacing.small)
        }
    }

    private var locationInfoView: some View {
        Group {
            DSTextField(text: $viewModel.displayName)
                .label(.localized(LocationKeys.displayName))
                .focused($focusField, equals: .displayName)
                .onSubmit {
                    focusField = .notes
                }
            DSTextField(text: $viewModel.name)
                .label(.localized(LocationKeys.name))
                .multiline()
                .enabled(false)
            DSTextField(text: $viewModel.address)
                .label(.localized(LocationKeys.address))
                .multiline()
                .enabled(false)
            HStack {
                DSTextField(text: $viewModel.latitude)
                    .label(.localized(LocationKeys.latitude))
                    .enabled(false)
                DSTextField(text: $viewModel.longitude)
                    .label(.localized(LocationKeys.longitude))
                    .enabled(false)
            }
            DSTextField(text: $viewModel.notes)
                .label(.localized(LocationKeys.notes))
                .multiline()
                .focused($focusField, equals: .notes)
        }
    }

    private var selectCategoryView: some View {
        NavigationStack {
            List {
                ForEach(viewModel.categories) { item in
                    DSText(item.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.category = item
                            showCategoryList = false
                        }
                }
            }
            .navigationTitle(Text(CategoryKeys.title))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showCategoryList = false
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
        }
    }
}

extension EditLocationView {
    private func saveLocation() {
        func handleLocationResult(_ location: Location?) {
            if let location {
                onSave(location)
                dismiss()
            } else {
                showErrorAlert = true
            }
        }

        switch editMode {
        case .add:
            viewModel.createLocation { location in
                handleLocationResult(location)
            }
        case .update:
            viewModel.updateLocation(locationToUpdate: locationToSave) { location in
                handleLocationResult(location)
            }
        }
    }
}

#Preview {
    EditLocationView(
        AppContainer.shared.makeEditLocationViewModel(),
        editMode: .add
    ) { _ in }
}
