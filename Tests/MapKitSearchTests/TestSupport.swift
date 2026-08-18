import Foundation

extension Double {
    /// Compares to two decimal places, enough to pin down a degree value
    /// without depending on the exact constants.
    func isApproximately(_ other: Double, tolerance: Double = 0.01) -> Bool {
        abs(self - other) <= tolerance
    }
}
