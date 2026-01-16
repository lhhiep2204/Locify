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
    let onAddLocation: () -> Void
    let onEditLocation: () -> Void
    let onDeleteLocation: () -> Void
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
            VStack(alignment: .leading) {
                DSText(
                    location.displayName.isEmpty ? location.name : location.displayName,
                    font: .bold(.xLarge)
                )
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .padding(.top, DSSpacing.xSmall)

                DSText(
                    location.address,
                    font: .regular(.small)
                )
            }

            Spacer()

            if location.isTemporary {
                addButtonView
                shareButtonView(location)
            } else {
                Menu {
                    shareButtonMenuView(location)
                    editButtonMenuView
                    Divider()
                    deleteButtonMenuView
                } label: {
                    Image.appSystemIcon(.more)
                        .circularGlassEffect()
                }
                .menuOrder(.fixed)
            }

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

    private var addButtonView: some View {
        Button {
            onAddLocation()
        } label: {
            Image.appSystemIcon(.add)
        }
        .circularGlassEffect()
    }

    private func shareButtonView(_ location: Location) -> some View {
        ShareLink(item: location.shareMessage) {
            Image.appSystemIcon(.share)
        }
        .circularGlassEffect()
    }

    private func shareButtonMenuView(_ location: Location) -> some View {
        ShareLink(item: location.shareMessage) {
            Label {
                DSText(.localized(CommonKeys.share))
            } icon: {
                Image.appSystemIcon(.share)
            }
        }
        .tint(.blue)
        .circularGlassEffect()
    }

    private var editButtonMenuView: some View {
        Button {
            onEditLocation()
        } label: {
            Label {
                DSText(.localized(CommonKeys.edit))
            } icon: {
                Image.appSystemIcon(.edit)
            }
        }
        .circularGlassEffect()
    }

    private var deleteButtonMenuView: some View {
        Button {
            onDeleteLocation()
        } label: {
            Label {
                DSText(.localized(CommonKeys.delete))
            } icon: {
                Image.appSystemIcon(.delete)
            }
        }
        .tint(.red)
        .circularGlassEffect()
    }

    private func infoView(location: Location) -> some View {
        Section {
            Group {
                nameView(name: location.name)
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

    private func coordinatesView(
        latitude: Double,
        longitude: Double
    ) -> some View {
        HStack {
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

            Spacer()

            Button {
                CommonHelper.Clipboard.copy(
                """
                \(String.localized(LocationKeys.latitude)): \(latitude)
                \(String.localized(LocationKeys.longitude)): \(longitude)
                """
                )
            } label: {
                Image.appSystemIcon(.copy)
                    .font(.appFont(.regular(.small)))
            }
            .buttonStyle(.plain)
            .circularGlassEffect()
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
                        item.displayName.isEmpty ? item.name : item.displayName,
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
    onAddLocation: { }
    onEditLocation: { }
    onDeleteLocation: { }
    onCloseSelectedLocation: { }
}
