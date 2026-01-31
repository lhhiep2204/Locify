//
//  MapView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import MapKit
import SwiftUI

struct MapView: View {
    @Binding var selectedLocation: Location?
    let locations: [Location]
    var onMapLocationSelected: (Location) -> Void

    @State private var position: MapCameraPosition = .automatic
    @State private var selection: MapSelection<Int>?

    var body: some View {
        Map(position: $position, selection: $selection) {
            ForEach(locations) { item in
                Annotation(
                    item.name,
                    coordinate: .init(
                        latitude: item.latitude,
                        longitude: item.longitude
                    ),
                    anchor: .bottom
                ) {
                    Image.appIcon(.marker)
                        .onTapGesture {
                            if selectedLocation == item {
                                updateCamera()
                            } else {
                                selectedLocation = item
                            }
                        }
                }
            }

            UserAnnotation()
        }
        .mapControlVisibility(.hidden)
        .onAppear { updateCamera() }
        .onChange(of: selectedLocation) {
            updateCamera()

            if selectedLocation?.id != Constants.mapSelectionId {
                selection = nil
            }
        }
        .onChange(of: selection) {
            guard let feature = selection?.feature else { return }

            Task {
                do {
                    let location = try await AppleMapService.shared.getSelectedMapLocationInfo(
                        name: feature.title,
                        for: feature.coordinate
                    )
                    onMapLocationSelected(location)
                } catch {
                    Logger.error(error.localizedDescription)
                }
            }
        }
    }
}

private extension MapView {
    private func updateCamera() {
        if let location = selectedLocation {
            switch location.id {
            case Constants.myLocationId:
                position = .userLocation(fallback: .automatic)
            default:
                position = .item(AppleMapService.shared.makeMapItem(from: location))
            }
        } else {
            position = .automatic
        }
    }
}

#Preview {
    MapView(
        selectedLocation: .constant(.mock),
        locations: Location.mockList
    ) { _ in }
}
