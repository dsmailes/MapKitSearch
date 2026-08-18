import MapKit
import Testing
@testable import MapKitSearch

@Suite("MapKitSearchModel")
@MainActor
struct MapKitSearchModelTests {

    @Test("a search term is forwarded to the completer")
    func searchTermDrivesCompleter() {
        let model = MapKitSearchModel()
        model.searchTerm = "Edinburgh"

        #expect(model.searchCompleter.queryFragment == "Edinburgh")
    }

    @Test("a blank search term clears results instead of querying")
    func blankSearchTermClearsResults() {
        let model = MapKitSearchModel()
        model.searchTerm = "Edinburgh"
        model.searchTerm = "   "

        #expect(model.searchCompleter.queryFragment.isEmpty)
        #expect(model.autoCompleteResults.isEmpty)
    }

    @Test("a late completer failure is ignored after clearing the query")
    func lateFailureAfterClearingQueryIsIgnored() {
        let model = MapKitSearchModel()
        model.searchTerm = "Edinburgh"
        model.searchTerm = "   "

        model.apply(error: TestError.failed)

        #expect(model.lastError == nil)
        #expect(model.autoCompleteResults.isEmpty)
    }

    @Test("an initial region biases the completer")
    func initialRegionIsApplied() throws {
        let expected = try #require(GeographicRegion.ukAndIreland.coordinateRegion)
        let model = MapKitSearchModel(region: expected)

        #expect(model.searchCompleter.region.center.latitude.isApproximately(expected.center.latitude))
        #expect(model.searchCompleter.region.span.latitudeDelta.isApproximately(expected.span.latitudeDelta))
    }

}

private enum TestError: Error {
    case failed
}
