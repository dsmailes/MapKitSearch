import MapKit
import Testing
@testable import MapKitSearch

@Suite("MKCoordinateRegion(coordinates:)")
struct CoordinateRegionTests {

    @Test("no coordinates produces no region")
    func emptyIsNil() {
        #expect(MKCoordinateRegion(coordinates: []) == nil)
    }

    @Test("a single coordinate produces a one-degree region")
    func singleCoordinate() throws {
        let coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12)
        let region = try #require(MKCoordinateRegion(coordinates: [coordinate]))

        #expect(region.center.latitude.isApproximately(51.5))
        #expect(region.center.longitude.isApproximately(-0.12))
        #expect(region.span.latitudeDelta.isApproximately(1))
        #expect(region.span.longitudeDelta.isApproximately(1))
    }

    @Test("repeated coordinates collapse to a point")
    func repeatedCoordinates() throws {
        let coordinate = CLLocationCoordinate2D(latitude: 10, longitude: 20)
        let region = try #require(MKCoordinateRegion(coordinates: [coordinate, coordinate]))

        #expect(region.center.latitude.isApproximately(10))
        #expect(region.center.longitude.isApproximately(20))
        #expect(region.span.longitudeDelta.isApproximately(0))
    }

    @Test("a pair straddling the antimeridian wraps the short way")
    func straddlesAntimeridian() throws {
        let region = try #require(MKCoordinateRegion(coordinates: [
            CLLocationCoordinate2D(latitude: 0, longitude: 170),
            CLLocationCoordinate2D(latitude: 0, longitude: -170),
        ]))

        #expect(region.span.longitudeDelta.isApproximately(20))
        #expect(abs(region.center.longitude).isApproximately(180))
    }

    @Test("the enclosing region covers every input coordinate")
    func enclosesInputs() throws {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 10, longitude: -5),
            CLLocationCoordinate2D(latitude: -20, longitude: 30),
            CLLocationCoordinate2D(latitude: 40, longitude: 15),
        ]
        let region = try #require(MKCoordinateRegion(coordinates: coordinates))

        #expect(region.span.latitudeDelta.isApproximately(60))
        #expect(region.span.longitudeDelta.isApproximately(35))
        #expect(region.center.latitude.isApproximately(10))
        #expect(region.center.longitude.isApproximately(12.5))
    }

}
