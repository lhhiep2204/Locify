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
    let onSearchLocation: () -> Void
    let onCloseSelectedLocation: () -> Void

    var body: some View {
        Group {
            if let location {
                VStack(alignment: .leading, spacing: DSSpacing.medium) {
                    topView(location: location)
                        .padding(.horizontal, DSSpacing.xLarge)

                    List {
                        infoView(location: location)

                        if !relatedLocations.isEmpty {
                            relatedLocationSection
                        }
                    }
                    .id(location.id)
                    .scrollContentBackground(.hidden)
                }
            } else {
                ScrollView {
                    DSText(.localized(HomeKeys.locationEmpty))
                        .padding(DSSpacing.large)
                }
            }
        }
        .padding(.top, DSSpacing.xLarge)
    }
}

extension LocationDetailView {
    private func topView(location: Location) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.small) {
            DSText(
                location.displayName,
                font: .bold(.xLarge)
            )
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .padding(.top, DSSpacing.xSmall)

            Spacer()

            Button {
                onSearchLocation()
            } label: {
                Image.appSystemIcon(.search)
                    .frame(height: DSSize.large)
            }
            .buttonStyle(.glass)

            if location.id != Constants.myLocationId || !relatedLocations.isEmpty {
                Button {
                    onCloseSelectedLocation()
                } label: {
                    Image.appSystemIcon(.close)
                        .frame(height: DSSize.large)
                }
                .buttonStyle(.glass)
            }
        }
    }

    private func infoView(location: Location) -> some View {
        Section {
            Group {
                nameView(name: location.name)
                addressView(address: location.address)
                coordinatesView(
                    latitude: location.latitude,
                    longitude: location.longitude
                )

                if let notes = location.notes {
                    notesView(notes: notes)
                }
            }
        } header: {
            DSText(
                .localized(HomeKeys.locationInfo),
                font: .regular(.small)
            )
        }
    }

    private func nameView(name: String) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xSmall) {
            infoItemView(
                title: .localized(LocationKeys.name),
                value: name
            )
        }
    }

    private func addressView(address: String) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xSmall) {
            infoItemView(
                title: .localized(LocationKeys.address),
                value: address
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
            infoItemView(
                title: .localized(LocationKeys.notes),
                value: notes
            )
        }
    }

    private func infoItemView(title: String, value: String) -> some View {
        Group {
            DSText(
                title,
                font: .bold(.small)
            )
            DSText(
                value,
                font: .regular(.medium)
            )
        }
    }

    private var relatedLocationSection: some View {
        Section {
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
        } header: {
            DSText(
                .localized(HomeKeys.relatedLocations),
                font: .regular(.small)
            )
        }
    }
}

#Preview {
    LocationDetailView(
        location: .constant(.mock),
        relatedLocations: Location.mockList
    ) { _ in }
    onSearchLocation: { }
    onCloseSelectedLocation: { }
}
