//
//  LocationDetailView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import SwiftUI

struct LocationDetailView: View {
    @Binding var location: Location?

    let routeDistance: Double?
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
                    ScrollView {
                        VStack(alignment: .leading, spacing: DSSpacing.large) {
                            topView(location: location)
                                .padding(.horizontal, DSSpacing.xLarge)

                            infoView(location: location)
                                .padding(.horizontal, DSSpacing.xLarge)

                            if !relatedLocations.isEmpty {
                                Divider()
                                    .padding(.horizontal, DSSpacing.xLarge)
                                relatedLocationSection
                            }
                        }
                        .padding(.top, DSSpacing.xLarge)
                    }
                } else {
                    VStack(alignment: .center, spacing: DSSpacing.medium) {
                        DSText(.localized(HomeKeys.locationEmpty))
                            .padding(DSSpacing.large)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(.horizontal, DSSpacing.large)
                }
            }

            bottomView
                .padding(.horizontal, DSSpacing.large)
        }
    }
}

extension LocationDetailView {
    private func topView(location: Location) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack(alignment: .top, spacing: DSSpacing.small) {
                let style = POIStyleHelper.style(for: location.category)

                Image(systemName: style.icon)
                    .font(.appFont(.medium(.small)))
                    .frame(width: DSSize.large, height: DSSize.large)
                    .background(
                        style.color.opacity(0.15),
                        in: RoundedRectangle(cornerRadius: DSRadius.large)
                    )

                DSText(
                    location.displayName.isEmpty ? location.name : location.displayName,
                    font: .bold(.large)
                )
                .lineLimit(3)
                .minimumScaleFactor(0.8)

                Spacer()

                actionMenu(location: location)

                if location.id != Constants.myLocationId || !relatedLocations.isEmpty {
                    closeButtonView
                        .padding(.top, -DSSpacing.small)
                }
            }

            if !location.name.isEmpty && !location.displayName.isEmpty {
                DSText(
                    location.name,
                    font: .regular(.small)
                )
            }
        }
    }

    private func actionMenu(location: Location) -> some View {
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
        .padding(.top, -DSSpacing.small)
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
        VStack(alignment: .leading, spacing: DSSpacing.small) {
            addressView(address: location.address)

            coordinatesView(
                latitude: location.latitude,
                longitude: location.longitude
            )

            if let notes = location.notes {
                notesView(notes: notes)
            }
        }
    }

    private func addressView(address: String) -> some View {
        HStack(alignment: .top) {
            infoItemView(
                icon: .address,
                title: .localized(LocationKeys.address),
                value: address
            )

            if let routeDistance {
                Spacer()

                DSText(
                    "\(routeDistance.formattedDistance)",
                    systemFont: .caption
                )
            }
        }
    }

    private func coordinatesView(
        latitude: Double,
        longitude: Double
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: DSSpacing.xSmall) {
                infoItemView(
                    icon: .coordinates,
                    title: .localized(LocationKeys.coordinates),
                    value: "\(latitude), \(longitude)"
                )
            }

            Spacer()

            Button {
                CommonHelper.Clipboard.copy("\(latitude), \(longitude)")
            } label: {
                Image.appSystemIcon(.copy)
                    .font(.appFont(.regular(.small)))
            }
            .buttonStyle(.plain)
            .circularGlassEffect(size: DSSize.xLarge)
        }
    }

    private func notesView(notes: String) -> some View {
        infoItemView(
            icon: .note,
            title: .localized(LocationKeys.notes),
            value: notes
        )
    }

    private func infoItemView(
        icon: DSSystemIcon,
        title: String,
        value: String
    ) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.medium) {
            Image.appSystemIcon(icon)
                .font(.appFont(.medium(.small)))
            VStack(alignment: .leading, spacing: DSSpacing.xSmall) {
                DSText(
                    title,
                    systemFont: .caption
                )
                DSText(
                    value,
                    systemFont: .subheadline.bold()
                )
            }
        }
    }

    private var relatedLocationSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.medium) {
            DSText(
                .localized(HomeKeys.relatedLocations),
                font: .regular(.small)
            )
            .padding(.bottom, -DSSpacing.small)
            .padding(.horizontal, DSSpacing.xLarge)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.medium) {
                    ForEach(relatedLocations) { item in
                        relatedLocationItem(item)
                    }
                }
                .padding(.horizontal, DSSpacing.xLarge)
            }
        }
    }

    private func relatedLocationItem(_ location: Location) -> some View {
        Button {
            onSelectLocation(location.id)
        } label: {
            VStack(alignment: .center, spacing: DSSpacing.medium) {
                let style = POIStyleHelper.style(for: location.category)
                Image(systemName: style.icon)
                    .font(.appFont(.medium(.medium)))
                    .frame(width: DSSize.huge, height: DSSize.huge)
                    .background(
                        style.color.opacity(0.15),
                        in: RoundedRectangle(cornerRadius: DSRadius.xxLarge)
                    )

                VStack(alignment: .leading, spacing: DSSpacing.xSmall) {
                    DSText(
                        location.displayName.isEmpty ? location.name : location.displayName,
                        systemFont: .caption.weight(.semibold)
                    )
                    .lineLimit(1)

                    DSText(
                        location.address,
                        systemFont: .caption2
                    )
                    .lineLimit(1)
                }
            }
            .frame(width: 150)
            .padding(DSSpacing.medium)
            .background(
                .backgroundPrimaryInverted.opacity(0.1),
                in: RoundedRectangle(cornerRadius: DSRadius.xLarge)
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
        routeDistance: 12.0,
        relatedLocations: Location.mockList
    ) { _ in }
    onSearchLocation: { }
    onAddLocation: { }
    onEditLocation: { }
    onDeleteLocation: { }
    onCloseSelectedLocation: { }
}
