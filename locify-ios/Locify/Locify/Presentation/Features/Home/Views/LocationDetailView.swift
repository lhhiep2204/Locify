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
        Group {
            if let location {
                VStack(alignment: .leading, spacing: DSSpacing.medium) {
                    DSText(
                        location.displayName,
                        font: .bold(.xLarge)
                    )
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
                        .padding(.bottom, DSSpacing.large)
                    }
                    .id(location.id)
                }
            } else {
                ScrollView {
                    DSText(.localized(HomeKeys.locationEmpty))
                        .padding(DSSpacing.large)
                }
            }
        }
        .padding(.top, DSSpacing.xLarge)
        .padding(.horizontal, DSSpacing.large)
    }
}

extension LocationDetailView {
    private func infoView(location: Location) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.medium) {
            nameView(name: location.name)
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
        VStack(alignment: .leading, spacing: DSSpacing.xSmall) {
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
        VStack(alignment: .leading, spacing: DSSpacing.xSmall) {
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
        VStack(alignment: .leading, spacing: DSSpacing.xSmall) {
            DSText(
                .localized(LocationKeys.coordinates),
                font: .bold(.small)
            )
            HStack {
                DSText(
                    .localized(LocationKeys.latitude),
                    font: .medium(.small)
                )
                DSText(
                    String(latitude),
                    font: .regular(.small)
                )
            }
            HStack {
                DSText(
                    .localized(LocationKeys.longitude),
                    font: .medium(.small)
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
        VStack(alignment: .leading, spacing: DSSpacing.medium) {
            DSText(
                .localized(HomeKeys.relatedLocations),
                font: .bold(.small)
            )

            Divider()

            ForEach(relatedLocations) { item in
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
                    onSelectLocation(item.id)
                }
            }
        }
        .dsContainerStyle()
    }
}

#Preview {
    LocationDetailView(
        location: .constant(.mock),
        relatedLocations: Location.mockList
    ) { _ in }
}
