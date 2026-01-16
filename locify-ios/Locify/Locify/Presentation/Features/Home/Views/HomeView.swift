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
    @State private var showEditLocationView: Bool = false

    @State private var showDeleteAlert: Bool = false

    private var categoryRouter: Router<Route> = .init(root: .categoryList)

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
        .alert(
            Text(MessageKeys.permissionDeniedTitle),
            isPresented: $viewModel.permissionDenied
        ) {
            Button(
                String.localized(CommonKeys.settings)
            ) {
                showLocationDetail = true

                URLHelper.openAppSettings()
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
        .alert(
            Text(
                String(
                    format: MessageKeys.deleteAlertTitle.rawValue, selectedLocation.wrappedValue?.name ?? .empty
                )
            ),
            isPresented: $showDeleteAlert
        ) {
            Button(
                String.localized(CommonKeys.delete),
                role: .destructive
            ) {
                showLocationDetail = true

                Task {
                    await viewModel.deleteLocation()
                }
            }
            Button(
                String.localized(CommonKeys.cancel),
                role: .cancel
            ) {
                showLocationDetail = true
            }
        } message: {
            Text(MessageKeys.deleteAlertMessage.rawValue)
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
        } onEditLocation: {
            showEditLocationView = true
        } onDeleteLocation: {
            showDeleteAlert = true
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
            RouterView(
                Router<Route>(
                    root: .search { location in
                        viewModel.selectLocationFromSearch(location)
                    }
                )
            )
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
        .sheet(isPresented: $showEditLocationView) {
            EditLocationView(
                container.makeEditLocationViewModel(),
                editMode: .update,
                category: viewModel.selectedCategory,
                locationToSave: viewModel.selectedLocation
            ) { location in
                Task {
                    await viewModel.updateLocation(location)
                }
            }
        }
    }
}

#Preview {
    HomeView(AppContainer.shared.makeHomeViewModel())
}
