# MapKitSearch

Location auto-complete for SwiftUI, built on `MKLocalSearchCompleter`. Type a
query, observe the completions, resolve the one the user picks into map items.

## Requirements

| | |
|---|---|
| Swift | 6.0 |
| Platforms | iOS 17 · macOS 14 · tvOS 17 · watchOS 10 · visionOS 1 |

## Installation

Add the package in Xcode via **File ▸ Add Package Dependencies**, or in a
`Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/dsmailes/MapKitSearch.git", from: "1.0.0")
]
```

> No version is tagged yet, so until one is, depend on the branch instead:
> `.package(url: "...", branch: "main")`.

## Usage

`MapKitSearchModel` is an `@Observable` model with the completer delegate
already wired up. Assigning to `searchTerm` starts a new completion, and
`autoCompleteResults` updates as MapKit responds.

```swift
import MapKit
import MapKitSearch
import SwiftUI

struct LocationSearchView: View {
    @State private var search = MapKitSearchModel(
        region: GeographicRegion.ukAndIreland.coordinateRegion
    )

    var body: some View {
        NavigationStack {
            List(search.autoCompleteResults, id: \.self) { completion in
                Button {
                    select(completion)
                } label: {
                    VStack(alignment: .leading) {
                        Text(completion.title)
                        Text(completion.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .searchable(text: $search.searchTerm)
        }
    }

    private func select(_ completion: MKLocalSearchCompletion) {
        Task {
            let response = try await search.getMKLocalSearchResponse(
                from: completion,
                in: nil
            )
            print(response.mapItems)
        }
    }
}
```

Narrow the kinds of suggestion returned with `resultTypes`:

```swift
MapKitSearchModel(resultTypes: [.address])
```

When a completion fails, `autoCompleteResults` is cleared and the failure is
published on `lastError`.

### Bringing your own model

Conform to `MapKitSearchProtocol` to get `autoComplete()` and
`getMKLocalSearchResponse(from:in:)` for free. Conformers are `@MainActor` and
must be classes: MapKit delivers completer callbacks on the main queue, and
`MKLocalSearchCompleter.delegate` is a weak reference.

```swift
@MainActor
@Observable
final class SearchModel: MapKitSearchProtocol {
    var autoCompleteResults: [MKLocalSearchCompletion] = []
    var searchTerm = ""
    let searchCompleter = MKLocalSearchCompleter()
}
```

You are then responsible for the delegate wiring. `MKLocalSearchCompleterDelegate`
methods are `@objc optional`, which a Swift protocol extension cannot satisfy —
the Objective-C runtime never sees them — so the protocol cannot supply that
step for you. Use `MapKitSearchModel` unless you need your own.

## Regions

`GeographicRegion` provides coarse bounding boxes for biasing a search toward
part of the world:

```swift
let region = GeographicRegion.europe.coordinateRegion
```

Available cases: `africa`, `antarctica`, `asia`, `australia`, `europe`,
`northAmerica`, `southAmerica`, `ukAndIreland`.

Two lower-level helpers back it:

```swift
// The smallest region enclosing a set of coordinates. Handles the
// antimeridian, so a span across the 180th meridian takes the short way.
MKCoordinateRegion(coordinates: [tokyo, honolulu])

// A latitude/longitude box, as south-west and north-east corners.
BoundingBox(mapRect: mapView.visibleMapRect)
```

`BoundingBox` exposes `crossesAntimeridian` for regions such as Asia, where the
western longitude is numerically greater than the eastern longitude. Use
`contains(_:)` when checking whether a coordinate lies inside the box.
