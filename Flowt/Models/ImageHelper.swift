//
//  ImageHelper.swift
//  Flowt
//
//  Created by Wiktor Drab on 22/08/2025.
//

import UIKit

extension UIImage {
    func resized(to maxSize: CGFloat = 200) -> UIImage {
        let aspectRatio = size.width / size.height
        var newSize: CGSize
        if aspectRatio > 1 { // szeroki obraz
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else { // wysoki obraz
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func toBase64(maxSizeKB: Int = 500) -> String? {
        var quality: CGFloat = 0.8
        let minQuality: CGFloat = 0.1
        let maxBytes = maxSizeKB * 1024
        
        while quality >= minQuality {
            if let data = self.jpegData(compressionQuality: quality) {
                if data.count <= maxBytes {
                    return data.base64EncodedString()
                }
            }
            quality -= 0.1
        }
        
        return nil
    }
}
