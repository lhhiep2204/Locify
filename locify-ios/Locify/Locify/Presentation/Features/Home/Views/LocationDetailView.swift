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

                            if let notes = location.notes {
                                notesView(notes: notes)
                            }

                            if !relatedLocations.isEmpty {
                                relatedLocationSection
                            }
                        }
                        .id(location.id)
                        .scrollContentBackground(.hidden)
                        .listSectionSpacing(.compact)
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
        VStack(alignment: .leading) {
            HStack(spacing: DSSpacing.small) {
                DSText(
                    location.displayName.isEmpty ? location.name : location.displayName,
                    font: .bold(.xLarge)
                )
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .padding(.top, DSSpacing.xSmall)

                Spacer()

                Menu {
                    if location.isTemporary {
                        addButtonView
                        openInMapsButtonView(location)
                        copyButtonView(location)
                        shareButtonView(location)
                    } else {
                        editButtonView
                        openInMapsButtonView(location)
                        copyButtonView(location)
                        shareButtonView(location)
                        Divider()
                        deleteButtonView
                    }
                } label: {
                    Image.appSystemIcon(.more)
                        .circularGlassEffect()
                }
                .menuOrder(.fixed)

                if location.id != Constants.myLocationId || !relatedLocations.isEmpty {
                    closeButtonView
                }
            }

            DSText(
                location.address,
                font: .regular(.small)
            )
        }
    }

    private var addButtonView: some View {
        Button {
            onAddLocation()
        } label: {
            Label {
                DSText(.localized(CommonKeys.add))
            } icon: {
                Image.appSystemIcon(.add)
            }
        }
        .circularGlassEffect()
    }

    private func copyButtonView(_ location: Location) -> some View {
        Button {
            CommonHelper.Clipboard.copy(location.shareMessage)
        } label: {
            Label {
                DSText(.localized(CommonKeys.copy))
            } icon: {
                Image.appSystemIcon(.copy)
            }
        }
        .circularGlassEffect()
    }

    private func shareButtonView(_ location: Location) -> some View {
        ShareLink(
            item: location.shareMessage,
            preview: SharePreview(location.displayName.isEmpty ? location.name : location.displayName)
        ) {
            Label {
                DSText(.localized(CommonKeys.share))
            } icon: {
                Image.appSystemIcon(.share)
            }
        }
        .tint(.blue)
        .circularGlassEffect()
    }

    private func openInMapsButtonView(_ location: Location) -> some View {
        Button {
            guard let url = URL(string: location.appleMapsURL) else { return }

            UIApplication.shared.open(url)
        } label: {
            Label {
                DSText(.localized(CommonKeys.openInMaps))
            } icon: {
                Image.appSystemIcon(.map)
            }
        }
        .circularGlassEffect()
    }

    private var editButtonView: some View {
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

    private var deleteButtonView: some View {
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

    private var closeButtonView: some View {
        Button {
            onCloseSelectedLocation()
        } label: {
            Image.appSystemIcon(.close)
        }
        .circularGlassEffect()
    }

    private func infoView(location: Location) -> some View {
        Section {
            Group {
                if !location.name.isEmpty && !location.displayName.isEmpty {
                    nameView(name: location.name)
                }

                coordinatesView(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
            }
        } header: {
            DSText(
                .localized(HomeKeys.details),
                font: .regular(.small)
            )
            .padding(.bottom, -DSSpacing.small)
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
                CommonHelper.Clipboard.copy("\(latitude), \(longitude)")
            } label: {
                Image.appSystemIcon(.copy)
                    .font(.appFont(.regular(.small)))
            }
            .buttonStyle(.plain)
            .circularGlassEffect()
        }
    }

    private func notesView(notes: String) -> some View {
        Section {
            DSText(
                notes,
                font: .regular(.medium)
            )
        } header: {
            DSText(
                .localized(HomeKeys.notes),
                font: .regular(.small)
            )
            .padding(.bottom, -DSSpacing.small)
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
            VStack(alignment: .leading, spacing: DSSpacing.medium) {
                Divider()
                    .background(.backgroundSecondaryInverted)

                DSText(
                    .localized(HomeKeys.relatedLocations),
                    font: .regular(.small)
                )
                .padding(.bottom, -DSSpacing.small)
            }
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
