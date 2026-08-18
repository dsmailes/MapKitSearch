import MapKit
import Testing
@testable import MapKitSearch

@Suite("BoundingBox")
struct BoundingBoxTests {

    @Test("a map rect's minimum corner is its southern edge")
    func mapRectLatitudeIsNotInverted() {
        let box = BoundingBox(mapRect: .world)

        #expect(box.min.latitude < box.max.latitude)
        #expect(box.min.longitude < box.max.longitude)
        #expect(box.min.latitude.isApproximately(-85.05))
        #expect(box.max.latitude.isApproximately(85.05))
    }

    @Test("a display region's corners stay ordered", arguments: GeographicRegion.allCases)
    func displayRegionIsOrdered(_ region: GeographicRegion) {
        let box = BoundingBox(displayRegion: region)

        #expect(box.min.latitude < box.max.latitude)
    }

    @Test("Asia explicitly marks its antimeridian crossing")
    func asiaCrossesAntimeridian() {
        let box = BoundingBox(displayRegion: .asia)

        #expect(box.crossesAntimeridian)
        #expect(box.contains(CLLocationCoordinate2D(latitude: 35, longitude: 100)))
        #expect(box.contains(CLLocationCoordinate2D(latitude: 35, longitude: -170)))
        #expect(!box.contains(CLLocationCoordinate2D(latitude: 35, longitude: -100)))
    }

    @Test("a conventional box does not cross the antimeridian")
    func ukAndIrelandDoesNotCrossAntimeridian() {
        let box = BoundingBox(displayRegion: .ukAndIreland)

        #expect(!box.crossesAntimeridian)
        #expect(box.contains(CLLocationCoordinate2D(latitude: 55, longitude: -1)))
        #expect(!box.contains(CLLocationCoordinate2D(latitude: 55, longitude: 20)))
    }

}
