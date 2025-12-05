//
//  HomeView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 25/7/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.appContainer) private var container
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var viewModel: HomeViewModel

    @State private var showLocationDetail: Bool = true
    @State private var locationDetailDetent: PresentationDetent = .small

    @State private var showCategoryListView: Bool = false
    @State private var showSearchView: Bool = false
    @State private var showAddLocationView: Bool = false

    private var categoryRouter: Router<Route> = .init(root: .categoryList)
    private var searchRouter: Router<Route> = .init(root: .search)

    private var selectedLocation: Binding<Location?> {
        .init(
            get: { viewModel.selectedLocation },
            set: { viewModel.selectLocation($0) }
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
        .environment(\.selectLocation) { category, selectedId, locations in
            showCategoryListView = false
            viewModel.selectLocationFromCategoryList(
                category: category,
                id: selectedId,
                locations: locations
            )
        }
        .environment(\.selectSearchedLocation) { location in
            viewModel.selectLocationFromSearch(location)
        }
        .alert(
            Text(MessageKeys.permissionDeniedTitle),
            isPresented: $viewModel.permissionDenied
        ) {
            Button(
                String.localized(CommonKeys.settings)
            ) {
                showLocationDetail = true

                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
            Button(
                String.localized(CommonKeys.cancel),
                role: .cancel
            ) {
                showLocationDetail = true
            }
        } message: {
            Text(MessageKeys.permissionDeniedMessage)
        }
    }
}

extension HomeView {
    private var regularContentView: some View {
        NavigationSplitView {
            locationDetailView
        } detail: {
            mapView
                .toolbar(.hidden)
        }
    }

    private var compactContentView: some View {
        mapView
            .sheet(isPresented: $showLocationDetail) {
                NavigationStack {
                    locationDetailView
                }
                .if(viewModel.selectedLocationId != nil) {
                    $0.presentationDetents(
                        [.small, .fraction(0.90)],
                        selection: $locationDetailDetent
                    )
                } else: {
                    $0.presentationDetents([.small])
                }
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.enabled)
            }
            .onChange(of: viewModel.selectedLocationId) {
                locationDetailDetent = .small
            }
    }

    private var mapView: some View {
        ZStack {
            MapView(
                selectedLocation: selectedLocation,
                locations: viewModel.locationList.filter { $0.id != Constants.myLocationId }
            )
            topView
        }
    }

    private var topView: some View {
        VStack {
            HStack {
                showCategoryListButton
                Spacer()
                showUserLocationButton
            }
            Spacer()
        }
        .padding()
    }

    private var showCategoryListButton: some View {
        Button {
            showCategoryListView = true
        } label: {
            Image.appSystemIcon(.list)
        }
        .circularGlassEffect()
    }

    private var showUserLocationButton: some View {
        Button {
            Task {
                await viewModel.getUserLocation()
            }
        } label: {
            Image.appSystemIcon(.location)
        }
        .circularGlassEffect()
    }

    private var locationDetailView: some View {
        LocationDetailView(
            location: selectedLocation,
            relatedLocations: viewModel.relatedLocations
        ) { locationId in
            viewModel.selectRelatedLocation(locationId)
        } onSearchLocation: {
            showSearchView = true
        } onAddLocation: {
            showAddLocationView = true
        } onCloseSelectedLocation: {
            Task {
                await viewModel.clearSelectedLocation()
            }
            categoryRouter.popToRoot()
        }
        .toolbar(.hidden)
        .sheet(isPresented: $showCategoryListView) {
            RouterView(categoryRouter)
        }
        .sheet(isPresented: $showSearchView) {
            RouterView(searchRouter)
        }
        .sheet(isPresented: $showAddLocationView) {
            EditLocationView(
                container.makeEditLocationViewModel(),
                editMode: .add,
                category: viewModel.selectedCategory,
                locationToSave: viewModel.selectedLocation
            ) { location in
                Task {
                    await viewModel.addLocation(location)
                }
            }
        }
    }
}

#Preview {
    HomeView(AppContainer.shared.makeHomeViewModel())
}
