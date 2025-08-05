//
//  HomeView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 25/7/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var viewModel: HomeViewModel

    @State private var showLocationDetail: Bool = true
    @State private var locationDetailDetent: PresentationDetent = .fraction(0.25)

    @State private var showCategoryListView: Bool = false

    private var router: Router<Route> = .init(root: .categoryList)

    private var selectedLocation: Binding<Location?> {
        Binding<Location?>(
            get: { viewModel.selectedLocation },
            set: { newValue in
                viewModel.selectedLocationId = newValue?.id
            }
        )
    }

    init(_ viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
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
        .environment(\.dismissSheet) {
            showCategoryListView = false
        }
        .environment(\.selectLocation) { (selectedId, locations) in
            showCategoryListView = false

            viewModel.selectedLocationId = selectedId
            viewModel.locations = locations
        }
    }
}

extension HomeView {
    private var regularContentView: some View {
        NavigationSplitView {
            locationDetailView
        } detail: {
            mapView
        }
    }

    private var compactContentView: some View {
        mapView
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
            .onChange(of: viewModel.selectedLocationId) {
                locationDetailDetent = .fraction(0.25)
            }
    }

    private var mapView: some View {
        MapView(
            selectedLocation: selectedLocation,
            locations: viewModel.locations
        )
    }

    private var locationDetailView: some View {
        LocationDetailView(
            location: selectedLocation,
            relatedLocations: viewModel.relatedLocations
        ) { locationId in
            viewModel.selectedLocationId = locationId
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button {
                    showCategoryListView = true
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
        .sheet(isPresented: $showCategoryListView) {
            RouterView(router)
        }
    }
}

#Preview {
    HomeView(ViewModelFactory.shared.makeHomeViewModel())
}
