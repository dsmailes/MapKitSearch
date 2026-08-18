import MapKit
import Testing
@testable import MapKitSearch

@Suite("GeographicRegion")
struct GeographicRegionTests {

    @Test("every region resolves to a non-degenerate region", arguments: GeographicRegion.allCases)
    func regionIsUsable(_ region: GeographicRegion) throws {
        let coordinateRegion = try #require(region.coordinateRegion)

        #expect(coordinateRegion.span.latitudeDelta > 0)
        #expect(coordinateRegion.span.longitudeDelta > 0)
        #expect(CLLocationCoordinate2DIsValid(coordinateRegion.center))
    }

    @Test("corners are ordered south-west to north-east", arguments: GeographicRegion.allCases)
    func cornersAreOrdered(_ region: GeographicRegion) {
        let coordinates = region.coordinates

        #expect(coordinates.min.latitude < coordinates.max.latitude)
    }

    @Test("Asia takes the short way across the antimeridian")
    func asiaCrossesAntimeridian() throws {
        let region = try #require(GeographicRegion.asia.coordinateRegion)

        // West 25.6E to east 168.98W is ~165 degrees the short way, not ~194.
        #expect(region.span.longitudeDelta.isApproximately(165.43))
        #expect(region.center.longitude.isApproximately(108.30))
    }

    @Test("Antarctica spans every longitude")
    func antarcticaSpansTheGlobe() throws {
        let region = try #require(GeographicRegion.antarctica.coordinateRegion)

        #expect(region.span.longitudeDelta.isApproximately(360))
        #expect(region.center.longitude.isApproximately(0))
    }

    @Test("a region within one hemisphere is untransformed")
    func ukAndIrelandStaysInPlace() throws {
        let region = try #require(GeographicRegion.ukAndIreland.coordinateRegion)

        #expect(region.center.latitude.isApproximately(54.37))
        #expect(region.center.longitude.isApproximately(-6.16))
        #expect(region.span.longitudeDelta.isApproximately(21.0))
    }

}
