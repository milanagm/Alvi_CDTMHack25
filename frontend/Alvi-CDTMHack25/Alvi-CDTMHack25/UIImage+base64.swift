//
//  UIImage+base64.swift
//  Alvi-CDTMHack25
//
//  Created by Max Rosenblattl on 10.05.25.
//

import UIKit

extension UIImage {
    /// Returns a Base64‑encoded string of the image’s PNG representation.
    /// - Returns: Base64 string, or nil if PNG conversion fails.
    func toBase64PNG() -> String? {
        guard let pngData = self.pngData() else { return nil }
        return pngData.base64EncodedString(options: [])
    }

    /// Returns a Base64‑encoded string of the image’s JPEG representation,
    /// compressed to the given quality.
    /// - Parameter compressionQuality: JPEG quality between 0.0 and 1.0.
    /// - Returns: Base64 string, or nil if JPEG conversion fails.
    func toBase64JPEG(compressionQuality: CGFloat = 1.0) -> String? {
        guard let jpegData = self.jpegData(compressionQuality: compressionQuality) else { return nil }
        return jpegData.base64EncodedString(options: [])
    }
}
