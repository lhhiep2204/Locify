//
//  MapSnapshotView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 8/3/26.
//

import MapKit
import SwiftUI

struct MapSnapshotView: View {
    let coordinate: CLLocationCoordinate2D
    let category: String
    let showPin: Bool

    @State private var snapshotImage: UIImage?
    @State private var snapshotter: MKMapSnapshotter?
    @Environment(\.displayScale) private var displayScale

    init(
        latitude: CGFloat,
        longitude: CGFloat,
        category: String = .empty,
        showPin: Bool = true
    ) {
        self.coordinate = .init(latitude: latitude, longitude: longitude)
        self.category = category
        self.showPin = showPin
    }

    var body: some View {
        GeometryReader { geo in
            Group {
                if let image = snapshotImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray.opacity(0.2)
                        .overlay {
                            ProgressView()
                        }
                }
            }
            .task(id: displayScale) {
                await generateSnapshot(size: geo.size)
            }
        }
    }

    private func generateSnapshot(size: CGSize) async {
        snapshotter?.cancel()

        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center: coordinate, span: span(for: category))
        options.size = size
        options.scale = displayScale

        let current = MKMapSnapshotter(options: options)
        snapshotter = current

        do {
            let snapshot = try await current.start()
            snapshotImage = showPin ? addPinToSnapshot(snapshot) : snapshot.image
        } catch {
            // Ignore cancellation errors — triggered intentionally on re-render
            if (error as? MKError)?.code != .loadingThrottled {
                Logger.error("Snapshot failed: \(error.localizedDescription)")
            }
        }
    }

    private func addPinToSnapshot(_ snapshot: MKMapSnapshotter.Snapshot) -> UIImage {
        guard let pinImage = UIImage(named: "ic.marker") else { return snapshot.image }

        let pinSize = CGSize(width: 24, height: 28)
        let pinPoint = snapshot.point(for: coordinate)
        let pinOrigin = CGPoint(
            x: pinPoint.x - pinSize.width / 2,
            y: pinPoint.y - pinSize.height
        )

        let renderer = UIGraphicsImageRenderer(size: snapshot.image.size)
        return renderer.image { _ in
            snapshot.image.draw(at: .zero)
            pinImage.draw(in: CGRect(origin: pinOrigin, size: pinSize))
        }
    }
}

// MARK: - Dynamic Span
extension MapSnapshotView {
    private func span(for category: String) -> MKCoordinateSpan {
        switch category {
        // Large-scale natural/national features — very wide zoom
        case "nationalpark", "beach", "hiking", "skiing", "rockclimbing",
             "surfing", "kayaking", "campground", "rvpark":
            return .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
        // City-district scale — stadiums, airports, fairgrounds, universities
        case "stadium", "airport", "amusementpark", "fairground",
             "conventioncenter", "university", "zoo":
            return .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        // Neighbourhood scale — parks, golf courses, marinas
        case "park", "golf", "marina", "nationalmonument", "castle", "fortress":
            return .init(latitudeDelta: 0.02, longitudeDelta: 0.02)
        // Street / building level — most POIs (restaurants, shops, etc.)
        case "restaurant", "cafe", "bakery", "brewery", "winery", "distillery",
             "store", "foodmarket", "hotel", "hospital", "school", "library",
             "museum", "movietheater", "theater", "musicvenue", "nightlife",
             "spa", "fitnesscenter", "bank", "atm", "pharmacy", "police",
             "firestation", "postoffice", "publictransport", "parking",
             "gasstation", "evcharger", "carrental", "laundry", "beauty",
             "automotiverepair", "animalservice", "restroom", "mailbox",
             "bowling", "skating", "skatepark", "tennis", "swimming",
             "volleyball", "soccer", "baseball", "basketball",
             "minigolf", "gokart", "fishing", "planetarium", "aquarium",
             "landmark":
            return .init(latitudeDelta: 0.005, longitudeDelta: 0.005)
        // Unknown / no category — sensible mid-level default
        default:
            return .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        }
    }
}

#Preview {
    MapSnapshotView(
        latitude: Location.mock.latitude,
        longitude: Location.mock.longitude,
        category: Location.mock.category
    )
    .aspectRatio(2/1, contentMode: .fit)
    .cornerRadius(DSRadius.xxLarge)
    .padding()
}
