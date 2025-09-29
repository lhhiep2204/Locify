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
    @State private var locationDetailDetent: PresentationDetent = .small

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
        }
    }

    private var compactContentView: some View {
        mapView
            .sheet(isPresented: $showLocationDetail) {
                NavigationStack {
                    locationDetailView
                }
                .presentationDetents(
                    [.small, .medium, .fraction(0.90)],
                    selection: $locationDetailDetent
                )
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
                locations: viewModel.locations.filter { $0.id != Constants.myLocationId }
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
                .frame(height: DSSize.large)
        }
        .buttonStyle(.glass)
    }

    private var showUserLocationButton: some View {
        Button {
            Task {
                await viewModel.getUserLocation()
            }
        } label: {
            Image.appSystemIcon(.location)
                .frame(height: DSSize.large)
        }
        .buttonStyle(.glass)
    }

    private var locationDetailView: some View {
        LocationDetailView(
            location: selectedLocation,
            relatedLocations: viewModel.relatedLocations
        ) { locationId in
            viewModel.locations.removeAll { $0.id == Constants.myLocationId }
            viewModel.selectedLocationId = locationId
        } onSearchLocation: {
            Logger.info("Comming soon")
        } onCloseSelectedLocation: {
            viewModel.clearSelectedLocation()
            router.popToRoot()
        }
        .toolbar(.hidden)
        .sheet(isPresented: $showCategoryListView) {
            RouterView(router)
        }
    }
}

#Preview {
    HomeView(ViewModelFactory.shared.makeHomeViewModel())
}
