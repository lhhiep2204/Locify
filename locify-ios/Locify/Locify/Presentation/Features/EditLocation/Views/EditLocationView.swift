//
//  EditLocationView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 20/8/25.
//

import SwiftUI

struct EditLocationView: View {
    @Environment(\.dismiss) private var dismiss

    @FocusState private var editing

    @State private var textSearch: String = .empty
    @State private var categoryName: String
    @State private var displayName: String
    @State private var name: String
    @State private var address: String
    @State private var latitude: String
    @State private var longitude: String
    @State private var notes: String

    let editMode: EditMode
    let category: Category?
    let locationToUpdate: Location?
    let onSave: (Location) -> Void

    init(
        editMode: EditMode,
        category: Category? = nil,
        locationToUpdate: Location? = nil,
        onSave: @escaping (Location) -> Void
    ) {
        self.editMode = editMode
        self.category = category
        self.locationToUpdate = locationToUpdate
        self.onSave = onSave

        if let locationToUpdate {
            _categoryName = State(initialValue: category?.name ?? .empty)
            _displayName = State(initialValue: locationToUpdate.displayName)
            _name = State(initialValue: locationToUpdate.name)
            _address = State(initialValue: locationToUpdate.address)
            _latitude = State(initialValue: String(locationToUpdate.latitude))
            _longitude = State(initialValue: String(locationToUpdate.longitude))
            _notes = State(initialValue: locationToUpdate.notes ?? .empty)
        } else {
            _categoryName = State(initialValue: .empty)
            _displayName = State(initialValue: .empty)
            _name = State(initialValue: .empty)
            _address = State(initialValue: .empty)
            _latitude = State(initialValue: .empty)
            _longitude = State(initialValue: .empty)
            _notes = State(initialValue: .empty)
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
                            saveLocation()
                        } label: {
                            Text(String.localized(CommonKeys.save))
                        }
                    }
                }
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .interactiveDismissDisabled()
        }
    }
}

extension EditLocationView {
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.medium) {
                DSTextField(text: $textSearch)
                    .image(.appSystemIcon(.search))
                    .focused($editing)

                Divider()
                    .padding(.vertical, DSSpacing.small)

                DSTextField(text: $categoryName)
                    .image(.appSystemIcon(.folder))
                    .trailingImage(.appSystemIcon(.chevronDown))
                    .disabled(true)

                Divider()
                    .padding(.vertical, DSSpacing.small)

                locationInfoView
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
            Text(LocationKeys.addLocation)
        case .update:
            Text(LocationKeys.updateLocation)
        }
    }

    private var locationInfoView: some View {
        Group {
            DSTextField(text: $displayName)
                .label(.localized(LocationKeys.displayName))
                .focused($editing)
            DSTextField(text: $name)
                .label(.localized(LocationKeys.name))
                .enabled(false)
            DSTextField(text: $address)
                .label(.localized(LocationKeys.address))
                .enabled(false)
            HStack {
                DSTextField(text: $latitude)
                    .label(.localized(LocationKeys.latitude))
                    .enabled(false)
                DSTextField(text: $longitude)
                    .label(.localized(LocationKeys.longitude))
                    .enabled(false)
            }
            DSTextField(text: $notes)
                .label(.localized(LocationKeys.notes))
                .multiline()
                .focused($editing)
        }
    }
}

extension EditLocationView {
    private func saveLocation() {
        var location: Location {
            if let locationToUpdate {
                var location = locationToUpdate
                location.displayName = displayName
                location.name = name
                location.address = address
                location.latitude = Double(latitude) ?? 0.0
                location.longitude = Double(longitude) ?? 0.0
                location.notes = notes
                return location
            } else {
                let location = Location(
                    categoryId: category?.id ?? UUID(),
                    displayName: displayName,
                    name: name,
                    address: address,
                    latitude: Double(latitude) ?? 0.0,
                    longitude: Double(longitude) ?? 0.0,
                    notes: notes
                )
                return location
            }
        }

        onSave(location)
        dismiss()
    }
}

#Preview {
    EditLocationView(editMode: .add, onSave: { _ in })
}
