//
//  EditLocationView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 20/8/25.
//

import SwiftUI

struct EditLocationView: View {
    @Environment(\.dismiss) private var dismiss

    let editMode: EditMode
    let locationToUpdate: Location?
    let onSave: (Location) -> Void

    init(
        editMode: EditMode,
        locationToUpdate: Location? = nil,
        onSave: @escaping (Location) -> Void
    ) {
        self.editMode = editMode
        self.locationToUpdate = locationToUpdate
        self.onSave = onSave
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
                .interactiveDismissDisabled()
        }
    }
}

extension EditLocationView {
    private var contentView: some View {
        Text(LocationKeys.name)
    }

    private var navigationTitle: Text {
        switch editMode {
        case .add:
            Text(LocationKeys.addLocation)
        case .update:
            Text(LocationKeys.updateLocation)
        }
    }
}

extension EditLocationView {
    private func saveLocation() {
        onSave(.mock)
        dismiss()
    }
}

#Preview {
    EditLocationView(editMode: .add, onSave: { _ in })
}
