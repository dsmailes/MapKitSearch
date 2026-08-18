import MapKit

// MARK: - GeographicRegion

/// Coarse bounding boxes for continents and other broad areas, useful for
/// biasing a search toward part of the world.
public enum GeographicRegion: String, CaseIterable, Sendable {

    case africa
    case antarctica
    case asia
    case australia
    case europe
    case northAmerica
    case southAmerica
    case ukAndIreland

    /// The region's extent in degrees.
    ///
    /// `east` may be numerically smaller than `west` for a region that crosses
    /// the antimeridian, as ``asia`` does.
    var degrees: (west: Double, south: Double, east: Double, north: Double) {
        switch self {
        case .africa:       (-25.383911, -47.1313489, 63.8085939, 37.5359)
        case .antarctica:   (-180.0, -85.0511287798, 180.0, -60.1086999)
        case .asia:         (25.5886467, -12.2118513, -168.97788, 81.9661865)
        case .australia:    (110.9510339, -54.8337658, 159.2872223, -9.1870264)
        case .europe:       (-25.48824365, 32.5960451596, 74.3555001, 73.1927977675)
        case .northAmerica: (-172.66113495, 5.4961, -15.51269745, 83.6655766261)
        case .southAmerica: (-110.0281, -56.1455, -28.650543, 17.6606999)
        case .ukAndIreland: (-16.6649026112, 47.7502953806, 4.3354981542, 60.9916781275)
        }
    }

    /// The region's south-west and north-east corners.
    public var coordinates: (min: CLLocationCoordinate2D, max: CLLocationCoordinate2D) {
        let degrees = degrees
        return (
            min: CLLocationCoordinate2D(latitude: degrees.south, longitude: degrees.west),
            max: CLLocationCoordinate2D(latitude: degrees.north, longitude: degrees.east)
        )
    }

    /// The region as an `MKCoordinateRegion`, handling any antimeridian crossing.
    public var coordinateRegion: MKCoordinateRegion? {
        let coordinates = coordinates
        return MKCoordinateRegion(coordinates: [coordinates.min, coordinates.max])
    }

}

// MARK: - RegionUtility

public struct RegionUtility {

    public init() {}

    /// The `MKCoordinateRegion` covering a predefined geographic region.
    public func region(for region: GeographicRegion) -> MKCoordinateRegion? {
        region.coordinateRegion
    }

}
