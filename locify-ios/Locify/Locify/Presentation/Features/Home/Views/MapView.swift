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
    let onMapFeatureSelected: (String?, CLLocationCoordinate2D) -> Void

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

            onMapFeatureSelected(feature.title, feature.coordinate)
        }
    }
}

extension MapView {
    private func updateCamera() {
        withAnimation {
            if let location = selectedLocation {
                switch location.id {
                case Constants.myLocationId:
                    position = .userLocation(fallback: .automatic)
                default:
                    position = .item(makeMapItem(from: location))
                }
            } else {
                position = .automatic
            }
        }
    }

    func makeMapItem(from location: Location) -> MKMapItem {
        let clLocation = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )

        let mapItem = MKMapItem(
            location: clLocation,
            address: .init(
                fullAddress: location.address,
                shortAddress: nil
            )
        )

        mapItem.name = location.name

        return mapItem
    }
}

#Preview {
    MapView(
        selectedLocation: .constant(.mock),
        locations: Location.mockList
    ) { _, _ in }
}
