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
    let onAddLocation: (Location) -> Void
    let onCloseSelectedLocation: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
                    VStack(alignment: .center, spacing: DSSpacing.medium) {
                        DSText(.localized(HomeKeys.locationEmpty))
                            .padding(DSSpacing.large)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(.horizontal, DSSpacing.xLarge)
                }
            }
            .padding(.top, DSSpacing.xLarge)

            bottomView
                .padding(.horizontal, DSSpacing.large)
        }
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

            ShareLink(item: "location.infoToShare()") {
                Image.appSystemIcon(.share)
            }
            .circularGlassEffect()

            if location.id != Constants.myLocationId || !relatedLocations.isEmpty {
                Button {
                    onCloseSelectedLocation()
                } label: {
                    Image.appSystemIcon(.close)
                }
                .circularGlassEffect()
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

    private var bottomView: some View {
        HStack(alignment: .top, spacing: DSSpacing.small) {
            Spacer()

            if let location, location.isTemporary {
                Button {
                    onAddLocation(location)
                } label: {
                    Image.appSystemIcon(.add)
                        .font(.appFont(.regular(.large)))
                }
                .circularGlassEffect(size: 52)
            }

            Button {
                onSearchLocation()
            } label: {
                Image.appSystemIcon(.search)
                    .font(.appFont(.regular(.large)))
            }
            .circularGlassEffect(size: 52)
        }
    }
}

#Preview {
    LocationDetailView(
        location: .constant(.mock),
        relatedLocations: Location.mockList
    ) { _ in }
    onSearchLocation: { }
    onAddLocation: { _ in }
    onCloseSelectedLocation: { }
}
