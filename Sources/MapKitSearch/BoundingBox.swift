import MapKit

// MARK: - BoundingBox

/// An axis-aligned latitude/longitude box, described by its south-west and
/// north-east corners.
///
/// For a box that crosses the antimeridian, ``min.longitude`` is greater than
/// ``max.longitude``. Use ``crossesAntimeridian`` or ``contains(_:)`` instead
/// of assuming that the longitude interval is numerically ascending.
public struct BoundingBox: Sendable {

    /// The south-west corner. For an antimeridian-crossing box, this is the
    /// western edge in geographic order, not the numerically smallest
    /// longitude.
    public let min: CLLocationCoordinate2D

    /// The north-east corner. For an antimeridian-crossing box, this is the
    /// eastern edge in geographic order, not the numerically largest
    /// longitude.
    public let max: CLLocationCoordinate2D

    /// Whether the box crosses the 180th meridian.
    public var crossesAntimeridian: Bool {
        min.longitude > max.longitude
    }

    public init(min: CLLocationCoordinate2D, max: CLLocationCoordinate2D) {
        self.min = min
        self.max = max
    }

    /// Creates the box covering a projected map rectangle.
    public init(mapRect: MKMapRect) {
        // MKMapRect's y axis increases *southwards*, so the rect's origin is
        // its north-west corner and (maxX, maxY) is its south-east corner.
        let northWest = MKMapPoint(x: mapRect.minX, y: mapRect.minY).coordinate
        let southEast = MKMapPoint(x: mapRect.maxX, y: mapRect.maxY).coordinate

        self.min = CLLocationCoordinate2D(latitude: southEast.latitude, longitude: northWest.longitude)
        self.max = CLLocationCoordinate2D(latitude: northWest.latitude, longitude: southEast.longitude)
    }

    /// Creates the box covering a predefined geographic region.
    public init(displayRegion: GeographicRegion) {
        let coordinates = displayRegion.coordinates
        self.min = coordinates.min
        self.max = coordinates.max
    }

    /// Returns whether a normalized coordinate lies inside the box.
    ///
    /// Coordinates should use MapKit's usual longitude range of -180...180.
    /// Latitude bounds are inclusive, as are both longitude edges.
    public func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        guard coordinate.latitude >= min.latitude,
              coordinate.latitude <= max.latitude
        else { return false }

        if crossesAntimeridian {
            return coordinate.longitude >= min.longitude || coordinate.longitude <= max.longitude
        }

        return coordinate.longitude >= min.longitude && coordinate.longitude <= max.longitude
    }

}
