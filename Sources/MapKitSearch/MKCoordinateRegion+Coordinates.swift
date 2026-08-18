import MapKit

// MARK: - MKCoordinateRegion Extension

extension MKCoordinateRegion {

    /// Creates the smallest region enclosing `coordinates`, choosing between a
    /// prime-meridian and an antimeridian-shifted frame so that a set spanning
    /// the 180th meridian does not wrap the long way around the globe.
    ///
    /// Returns `nil` if `coordinates` is empty.
    public init?(coordinates: [CLLocationCoordinate2D]) {
        let primeRegion = MKCoordinateRegion.region(
            for: coordinates,
            transform: { $0 },
            inverseTransform: { $0 }
        )

        let transformedRegion = MKCoordinateRegion.region(
            for: coordinates,
            transform: MKCoordinateRegion.transform,
            inverseTransform: MKCoordinateRegion.inverseTransform
        )

        // The shift maps -180 and +180 onto the same value, so for a set that
        // genuinely spans every longitude it collapses to a zero-width region.
        // Discard such a candidate unless the input really is a single meridian.
        let spansOneMeridian = Set(coordinates.map(\.longitude)).count == 1
        let candidates = [primeRegion, transformedRegion]
            .compactMap { $0 }
            .filter { spansOneMeridian || $0.span.longitudeDelta > 0 }

        guard let smallest = candidates.min(by: { $0.span.longitudeDelta < $1.span.longitudeDelta })
        else { return nil }

        self = smallest
    }

    private static func transform(c: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        c.longitude < 0 ? CLLocationCoordinate2DMake(c.latitude, 360 + c.longitude) : c
    }

    private static func inverseTransform(c: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        c.longitude > 180 ? CLLocationCoordinate2DMake(c.latitude, -360 + c.longitude) : c
    }

    private static func region(
        for coordinates: [CLLocationCoordinate2D],
        transform: (CLLocationCoordinate2D) -> CLLocationCoordinate2D,
        inverseTransform: (CLLocationCoordinate2D) -> CLLocationCoordinate2D
    ) -> MKCoordinateRegion? {
        guard !coordinates.isEmpty else { return nil }

        if coordinates.count == 1 {
            return MKCoordinateRegion(
                center: coordinates[0],
                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            )
        }

        let transformed = coordinates.map(transform)
        let latitudes = transformed.map(\.latitude)
        let longitudes = transformed.map(\.longitude)

        guard let minLat = latitudes.min(), let maxLat = latitudes.max(),
              let minLon = longitudes.min(), let maxLon = longitudes.max()
        else { return nil }

        let span = MKCoordinateSpan(latitudeDelta: maxLat - minLat, longitudeDelta: maxLon - minLon)
        let center = inverseTransform(CLLocationCoordinate2DMake((minLat + maxLat) / 2, (minLon + maxLon) / 2))

        return MKCoordinateRegion(center: center, span: span)
    }

}
