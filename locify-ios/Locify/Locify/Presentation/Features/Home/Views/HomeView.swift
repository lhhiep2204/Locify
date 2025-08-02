//
//  HomeView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 25/7/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State var viewModel: HomeViewModel

    @State private var showLocationDetail: Bool = true
    @State private var locationDetailDetent: PresentationDetent = .fraction(0.25)

    @State private var showCategoryListView: Bool = false

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
        .task {
            await viewModel.fetchCategories()
            await viewModel.fetchLocations()
        }
    }
}

extension HomeView {
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
        MapView(
            selectedLocation: $viewModel.selectedLocation,
            locations: viewModel.locations
        )
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
        LocationDetailView(
            location: $viewModel.selectedLocation,
            relatedLocations: viewModel.relatedLocations
        )
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
            CategoryListView(categories: viewModel.categories)
        }
    }
}

#Preview {
    HomeView(ViewModelFactory.shared.makeHomeViewModel())
}
