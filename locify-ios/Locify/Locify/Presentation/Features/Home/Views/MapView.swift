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
                Marker(
                    item.name,
                    coordinate: .init(
                        latitude: item.latitude,
                        longitude: item.longitude
                    )
                )
            }
        }
        .onAppear { updateCamera() }
        .onChange(of: selectedLocation) { (_, _) in
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
    MapView(
        selectedLocation: .constant(Location.mockList.first!),
        locations: Location.mockList
    )
}
