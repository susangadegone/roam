import SwiftUI
import MapKit

struct MapView: View {
    @Environment(ResourceStore.self) private var store
    @State private var selectedResource: Resource? = nil
    @State private var navigateTo: Resource? = nil
    @State private var viewMode: ViewMode = .map
    @State private var query: String = ""
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.758, longitude: -122.435),
            span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
        )
    )

    enum ViewMode: String, CaseIterable {
        case map = "Map"
        case list = "List"
    }

    private var mappable: [Resource] {
        store.resources.filter { $0.hasCoordinates }
    }

    private var listResults: [Resource] {
        let base = store.resources.sorted { $0.distanceMiles < $1.distanceMiles }
        guard !query.isEmpty else { return base }
        return base.filter { r in
            r.name.localizedCaseInsensitiveContains(query)
            || r.shortDescription.localizedCaseInsensitiveContains(query)
            || r.neighborhood.localizedCaseInsensitiveContains(query)
            || r.category.rawValue.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Theme.canvas.ignoresSafeArea()

                switch viewMode {
                case .map:
                    mapContent
                case .list:
                    listContent
                }

                viewModePicker
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
            .ignoresSafeArea(edges: viewMode == .map ? .bottom : [])
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.canvas, for: .navigationBar)
            .navigationDestination(item: $navigateTo) { r in
                ResourceDetailView(resource: r)
            }
        }
    }

    private var viewModePicker: some View {
        Picker("View", selection: $viewMode) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .background(Theme.cream, in: RoundedRectangle(cornerRadius: 8))
    }

    private var mapContent: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                ForEach(mappable) { resource in
                    Annotation("", coordinate: CLLocationCoordinate2D(
                        latitude: resource.latitude!,
                        longitude: resource.longitude!
                    )) {
                        MapPin(
                            resource: resource,
                            isSelected: selectedResource?.id == resource.id
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedResource = (selectedResource?.id == resource.id) ? nil : resource
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard)
            .onTapGesture {
                withAnimation(.easeOut(duration: 0.2)) { selectedResource = nil }
            }

            if let r = selectedResource {
                MapCallout(resource: r) {
                    navigateTo = r
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private var listContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Color.clear.frame(height: 44)
                listSearchBar
                if listResults.isEmpty {
                    emptyListState
                } else {
                    ForEach(listResults) { r in
                        ResourceCard(resource: r) { navigateTo = r }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    private var listSearchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Theme.cocoaMuted)
            TextField("Search places", text: $query)
                .font(.sans(15))
                .foregroundStyle(Theme.cocoa)
                .tint(Theme.terracotta)
                .submitLabel(.search)
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.cocoaMuted)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.cream))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
    }

    private var emptyListState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(Theme.cocoaMuted)
            Text("No results found.")
                .font(.serifTitle(18, weight: .semibold))
                .foregroundStyle(Theme.cocoa)
            Text("Try a different search.")
                .font(.sans(14))
                .foregroundStyle(Theme.cocoaMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.cream.opacity(0.6)))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
    }
}

// MARK: - Pin

private struct MapPin: View {
    let resource: Resource
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(resource.category.stripe)
                    .frame(width: isSelected ? 20 : 14, height: isSelected ? 20 : 14)
                    .overlay(
                        Circle().strokeBorder(Theme.cream, lineWidth: isSelected ? 2.5 : 1.5)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
            }
            .scaleEffect(isSelected ? 1.15 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Bottom callout card

private struct MapCallout: View {
    let resource: Resource
    let onViewDetails: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(resource.category.stripe)
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            VStack(alignment: .leading, spacing: 3) {
                Text(resource.name)
                    .font(.serifTitle(16, weight: .semibold))
                    .foregroundStyle(Theme.cocoa)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(resource.category.rawValue.uppercased())
                        .font(.sans(11, weight: .semibold))
                        .tracking(0.5)
                        .foregroundStyle(Theme.cocoaMuted)
                    Text("·").foregroundStyle(Theme.cocoaMuted)
                    Text(resource.cost.rawValue)
                        .font(.sans(11))
                        .foregroundStyle(Theme.cocoaMuted)
                }
            }

            Spacer()

            Button(action: onViewDetails) {
                Text("View")
                    .font(.sans(14, weight: .semibold))
                    .foregroundStyle(Theme.cream)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Theme.terracotta))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.cream)
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Theme.cocoaBorder, lineWidth: 1)
        )
    }
}

#Preview {
    MapView()
        .environment(ResourceStore())
        .environment(SavedStore())
}
