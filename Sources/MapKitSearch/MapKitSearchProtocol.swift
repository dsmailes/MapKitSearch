import MapKit

// MARK: - MapKitSearchProtocol

/// Drives MapKit's auto-complete search: feeds a query fragment to an
/// `MKLocalSearchCompleter` and resolves a chosen completion into map items.
///
/// Conformers are main actor isolated. MapKit delivers completer callbacks and
/// `MKLocalSearch` results on the main queue, and neither
/// `MKLocalSearchCompleter` nor `MKLocalSearchCompletion` is `Sendable`, so a
/// nonisolated conformance cannot be made data-race safe.
///
/// Conformers must forward `MKLocalSearchCompleterDelegate` callbacks into
/// ``autoCompleteResults`` themselves. Objective-C optional protocol methods
/// cannot be satisfied by a Swift protocol extension — the runtime never sees
/// them — so this protocol cannot supply that wiring for you. Use
/// ``MapKitSearchModel`` for an implementation that already does it.
@MainActor
public protocol MapKitSearchProtocol: AnyObject {

    var autoCompleteResults: [MKLocalSearchCompletion] { get set }
    var searchCompleter: MKLocalSearchCompleter { get }
    var searchTerm: String { get set }

    func getMKLocalSearchResponse(from completedSearchTerm: MKLocalSearchCompletion, in region: MKCoordinateRegion?) async throws -> MKLocalSearch.Response
    func autoComplete()

}

extension MapKitSearchProtocol {

    /// Sends the current ``searchTerm`` to the completer.
    ///
    /// An empty or whitespace-only term cancels the in-flight completion and
    /// clears ``autoCompleteResults``, rather than asking MapKit to complete
    /// nothing.
    public func autoComplete() {
        let queryFragment = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !queryFragment.isEmpty else {
            // `cancel()` alone leaves the previous fragment in place, so a
            // later read of the completer would still report the stale term.
            searchCompleter.queryFragment = ""
            searchCompleter.cancel()
            autoCompleteResults.removeAll()
            return
        }
        searchCompleter.queryFragment = queryFragment
    }

    public func getMKLocalSearchResponse(from completedSearchTerm: MKLocalSearchCompletion, in region: MKCoordinateRegion?) async throws -> MKLocalSearch.Response {
        let searchRequest = MKLocalSearch.Request(completion: completedSearchTerm)
        if let region {
            searchRequest.region = region
        }
        let search = MKLocalSearch(request: searchRequest)
        return try await search.start()
    }

}
