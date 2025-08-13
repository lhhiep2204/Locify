//
//  LocationDetailView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import SwiftUI

struct LocationDetailView: View {
    @Binding var location: Location?

    let relatedLocations: [Location]
    let onSelectLocation: (UUID) -> Void

    var body: some View {
        if let location {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DSSpacing.medium) {
                    infoView(location: location)

                    if let notes = location.notes {
                        notesView(notes: notes)
                    }

                    if !relatedLocations.isEmpty {
                        relatedLocationSection
                    }
                }
                .padding([.bottom, .horizontal], DSSpacing.large)
                .navigationTitle(location.displayName ?? location.name)
            }
            .id(location.id)
        } else {
            DSText(.localized(HomeKeys.locationEmpty))
        }
    }
}

extension LocationDetailView {
    private func infoView(location: Location) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.medium) {
            if !location.displayName.isNilOrEmpty {
                nameView(name: location.name)
            }

            addressView(address: location.address)
            coordinatesView(
                latitude: location.latitude,
                longitude: location.longitude
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsContainerStyle()
    }

    private func nameView(name: String) -> some View {
        VStack(alignment: .leading) {
            DSText(
                .localized(LocationKeys.name),
                font: .bold(.small)
            )
            DSText(
                name,
                font: .regular(.medium)
            )
        }
    }

    private func addressView(address: String) -> some View {
        VStack(alignment: .leading) {
            DSText(
                .localized(LocationKeys.address),
                font: .bold(.small)
            )
            DSText(
                address,
                font: .regular(.medium)
            )
        }
    }

    private func coordinatesView(
        latitude: Double,
        longitude: Double
    ) -> some View {
        VStack(alignment: .leading) {
            DSText(
                .localized(LocationKeys.coordinates),
                font: .bold(.small)
            )
            HStack {
                DSText(
                    .localized(LocationKeys.latitude),
                    font: .bold(.small)
                )
                DSText(
                    String(latitude),
                    font: .regular(.small)
                )
            }
            HStack {
                DSText(
                    .localized(LocationKeys.longitude),
                    font: .bold(.small)
                )
                DSText(
                    String(longitude),
                    font: .regular(.small)
                )
            }
        }
    }

    private func notesView(notes: String) -> some View {
        VStack(alignment: .leading) {
            DSText(
                .localized(LocationKeys.notes),
                font: .bold(.small)
            )
            DSText(
                notes,
                font: .regular(.medium)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsContainerStyle()
    }

    private var relatedLocationSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.small) {
            DSText(
                .localized(HomeKeys.relatedLocations),
                font: .bold(.small)
            )

            Divider()

            ForEach(relatedLocations) { item in
                VStack(alignment: .leading) {
                    DSText(
                        item.name,
                        font: .bold(.medium)
                    )
                    .lineLimit(1)

                    DSText(
                        item.address,
                        font: .medium(.small)
                    )
                    .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelectLocation(item.id)
                }
            }
        }
        .dsContainerStyle()
    }
}

#Preview {
    NavigationStack {
        LocationDetailView(
            location: .constant(.mock),
            relatedLocations: Location.mockList
        ) { _ in }
    }
}
