import MapKit
import Observation

// MARK: - MapKitSearchModel

/// An observable ``MapKitSearchProtocol`` implementation with the completer
/// delegate already wired up.
///
/// Assigning to ``searchTerm`` triggers completion, so a SwiftUI search field
/// bound to it keeps ``autoCompleteResults`` up to date:
///
/// ```swift
/// @State private var search = MapKitSearchModel(region: GeographicRegion.ukAndIreland.coordinateRegion)
///
/// var body: some View {
///     List(search.autoCompleteResults, id: \.self) { completion in
///         Text(completion.title)
///     }
///     .searchable(text: $search.searchTerm)
/// }
/// ```
@MainActor
@Observable
public final class MapKitSearchModel: MapKitSearchProtocol {

    /// Completions for the current ``searchTerm``, updated by MapKit.
    public var autoCompleteResults: [MKLocalSearchCompletion] = []

    /// The most recent completer failure, or `nil` if the last update succeeded.
    public private(set) var lastError: (any Error)?

    /// The term to complete. Setting it starts a new completion.
    public var searchTerm: String = "" {
        didSet {
            guard searchTerm != oldValue else { return }
            autoComplete()
        }
    }

    public let searchCompleter = MKLocalSearchCompleter()

    private let completerDelegate = CompleterDelegate()

    /// Creates a search model.
    ///
    /// - Parameters:
    ///   - region: Biases completions toward this area. Pass `nil` to let
    ///     MapKit choose, which usually means the user's current location.
    ///   - resultTypes: The kinds of completion MapKit should return.
    public init(
        region: MKCoordinateRegion? = nil,
        resultTypes: MKLocalSearchCompleter.ResultType = [.address, .pointOfInterest, .query]
    ) {
        searchCompleter.resultTypes = resultTypes
        if let region {
            searchCompleter.region = region
        }
        completerDelegate.owner = self
        searchCompleter.delegate = completerDelegate
    }

    func apply(results: [MKLocalSearchCompletion]) {
        // `MKLocalSearchCompleter.cancel()` is best effort. A callback from a
        // query that was just cleared must not repopulate the suggestions.
        guard !searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        autoCompleteResults = results
        lastError = nil
    }

    func apply(error: any Error) {
        guard !searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        autoCompleteResults.removeAll()
        lastError = error
    }

}

// MARK: - CompleterDelegate

/// Bridges `MKLocalSearchCompleter`'s Objective-C delegate callbacks back to a
/// ``MapKitSearchModel``.
///
/// `MKLocalSearchCompleter.delegate` is a weak reference, so the model owns
/// this object rather than acting as its own delegate.
@MainActor
private final class CompleterDelegate: NSObject, @preconcurrency MKLocalSearchCompleterDelegate {

    weak var owner: MapKitSearchModel?

    // MapKit delivers these callbacks on the main queue, so the scoped
    // `@preconcurrency` conformance keeps the legacy Objective-C boundary on
    // the model's main actor without crossing a non-Sendable results array.
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        owner?.apply(results: completer.results)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        owner?.apply(error: error)
    }

}
