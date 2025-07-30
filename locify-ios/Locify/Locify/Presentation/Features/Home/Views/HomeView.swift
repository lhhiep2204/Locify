//
//  HomeView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 25/7/25.
//

import MapKit
import SwiftUI

struct HomeView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State var viewModel: HomeViewModel

    @State private var showLocationDetail: Bool = true
    @State private var locationDetailDetent: PresentationDetent = .fraction(0.25)

    @State private var position: MapCameraPosition = .automatic

    init(_ viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        contentView
            .task {
                await viewModel.fetchLocations()
            }
    }
}

extension HomeView {
    @ViewBuilder
    private var contentView: some View {
        switch horizontalSizeClass {
        case .regular:
            regularContentView
        case .compact:
            compactContentView
                .toolbar(.hidden)
        default:
            EmptyView()
        }
    }

    private var regularContentView: some View {
        NavigationSplitView {
            locationDetailView
        } detail: {
            mapContentView
        }
    }

    private var compactContentView: some View {
        mapContentView
            .sheet(isPresented: $showLocationDetail) {
                NavigationStack {
                    locationDetailView
                }
                .presentationDetents(
                    [.fraction(0.25), .medium],
                    selection: $locationDetailDetent
                )
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.enabled)
            }
    }

    private var mapContentView: some View {
        ZStack {
            mapView
            topView
                .padding([.horizontal, .top], DSSpacing.small)
        }
    }

    private var mapView: some View {
        Map(position: $position) {
            if let location = viewModel.selectedLocation {
                Marker(coordinate: .init(
                    latitude: location.latitude,
                    longitude: location.longitude
                )) {
                    Text(location.name)
                }
            }
        }
    }

    private var topView: some View {
        VStack {
            HStack {
                Spacer()

                Button {

                } label: {
                    Image.appSystemIcon(.location)
                }
                .buttonStyle(.glass)
            }
            Spacer()
        }
    }

    private var locationDetailView: some View {
        VStack {
            ScrollView {
                Group {
                    if let location = viewModel.selectedLocation {
                        VStack(alignment: .leading) {
                            DSText(
                                location.name,
                                font: .bold(.large)
                            )
                            .lineLimit(1)

                            DSText(
                                location.address,
                                font: .medium(.medium)
                            )
                            .lineLimit(2)
                        }
                    } else {
                        DSText("Please select a location")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DSSpacing.large)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button {

                        } label: {
                            Image.appSystemIcon(.list)
                        }

                        Button {

                        } label: {
                            Image.appSystemIcon(.search)
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {

                        } label: {
                            Image.appSystemIcon(.settings)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(ViewModelFactory.shared.makeHomeViewModel())
}
