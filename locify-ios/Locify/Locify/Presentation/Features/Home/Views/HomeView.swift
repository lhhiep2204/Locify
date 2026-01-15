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
    @State private var locationDetailHeight: CGFloat = locationDetailMinHeight

    @State private var showCategoryListView: Bool = false
    @State private var showSearchView: Bool = false
    @State private var showAddLocationView: Bool = false

    private var categoryRouter: Router<Route> = .init(root: .categoryList)

    private var selectedLocation: Binding<Location?> {
        .init(
            get: { viewModel.selectedLocation },
            set: { viewModel.selectLocation($0) }
        )
    }

    private static let locationDetailMinHeight: CGFloat = 300

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
        ZStack {
            mapView
            VStack {
                Spacer()
                locationDetailContainerView
                    .onChange(of: viewModel.selectedLocationId) {
                        withAnimation(.spring) {
                            locationDetailHeight = HomeView.locationDetailMinHeight
                        }
                    }
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private var mapView: some View {
        ZStack {
            MapView(
                selectedLocation: selectedLocation,
                locations: viewModel.locationList.filter { $0.id != Constants.myLocationId }
            )
            .safeAreaPadding(.leading, DSSpacing.large)
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

    private var locationDetailContainerView: some View {
        ConcentricRectangle(corners: .concentric, isUniform: true)
            .fill(.backgroundPrimary.opacity(0.8))
            .frame(height: locationDetailHeight)
            .overlay {
                locationDetailView
            }
            .clipShape(ConcentricRectangle(corners: .concentric, isUniform: true))
            .padding(DSSpacing.large)
            .gesture(
                DragGesture()
                    .onChanged {
                        let height = $0.translation.height

                        if height < 0 {
                            locationDetailHeight = min(locationDetailHeight + abs(height), 550)
                        } else {
                            locationDetailHeight = max(locationDetailHeight - abs(height), 200)
                        }
                    }
                    .onEnded {
                        let height = $0.translation.height
                        withAnimation(.spring) {
                            locationDetailHeight = height > 0 ? 250 : 500
                        }
                    }
            )
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
    }
}

#Preview {
    HomeView(AppContainer.shared.makeHomeViewModel())
}
