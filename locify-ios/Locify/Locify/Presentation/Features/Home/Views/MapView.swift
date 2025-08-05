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

    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $position) {
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
        }
        .mapControls {
            MapUserLocationButton()
            MapPitchToggle()
            MapCompass()
            MapScaleView()
        }
        .onAppear { updateCamera() }
        .onChange(of: selectedLocation) {
            updateCamera()
        }
    }
}

private extension MapView {
    private func updateCamera() {
        withAnimation(.easeInOut) {
            if let location = selectedLocation {
                position = .region(.region(for: location))
            } else {
                position = .automatic
            }
        }
    }
}

#Preview {
    if let location = Location.mockList.first {
        MapView(
            selectedLocation: .constant(location),
            locations: Location.mockList
        )
    }
}
