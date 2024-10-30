// The Swift Programming Language
// https://docs.swift.org/swift-book

import Combine
import MapKit
import SwiftUI

public protocol MapKitSearchProtocol {

    var autoCompleteResults: [MKLocalSearchCompletion] { get set }
    var searchCompleter: MKLocalSearchCompleter { get }
    var searchTerm: String { get set }

    func getMKLocalSearchResponse(from completedSearchTerm: MKLocalSearchCompletion, in region: MKCoordinateRegion?) async throws -> MKLocalSearch.Response
    func autoComplete()

}

extension MapKitSearchProtocol {

    public func autoComplete() {
        searchCompleter.queryFragment = searchTerm
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
