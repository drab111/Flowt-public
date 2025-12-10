//
//  Island.swift
//  Flowt
//
//  Created by Wiktor Drab on 17/09/2025.
//

import SpriteKit

class Island: SKSpriteNode {
    private let radius: CGFloat
    
    // Cached image info for fast alpha sampling
    private var cgImage: CGImage?
    private var pixelData: CFData?
    private var imgWidth: Int = 0
    private var imgHeight: Int = 0
    private var bytesPerPixel: Int = 0
    private var bytesPerRow: Int = 0
    private var alphaChannelOffset: Int = 3 // RGBA order (R,G,B,A) -> alpha at 3
    
    init(position: CGPoint, radius: CGFloat, picture: String) {
        self.radius = radius
        let texture = SKTexture(imageNamed: picture)
        super.init(texture: texture, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
        
        self.position = position
        self.zPosition = 1
        self.name = "Island"
        
        addBlurredShadow(texture: texture, radius: radius)
        setupPixelCache(texture.cgImage())
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    // MARK: - Design
    private func addBlurredShadow(texture: SKTexture, radius: CGFloat) {
        let shadowNode = SKSpriteNode(texture: texture)
        shadowNode.size = CGSize(width: radius*2, height: radius*2)
        shadowNode.color = .black
        shadowNode.colorBlendFactor = 1.0
        shadowNode.alpha = 0.4
        
        let effectNode = SKEffectNode()
        effectNode.addChild(shadowNode)
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 4])
        effectNode.shouldRasterize = true
        effectNode.zPosition = -1
        effectNode.position = CGPoint(x: 2, y: -2)
        
        addChild(effectNode)
    }
    
    private func setupPixelCache(_ cgImage: CGImage) {
        self.cgImage = cgImage
        self.imgWidth = cgImage.width
        self.imgHeight = cgImage.height
        self.bytesPerRow = cgImage.bytesPerRow
        self.bytesPerPixel = cgImage.bitsPerPixel / 8
        
        if let provider = cgImage.dataProvider, let data = provider.data {
            self.pixelData = data
        } else { self.pixelData = nil }
    }
    
    // MARK: - Collision Helper
    func contains(point: CGPoint) -> Bool {
        // First a quick bounding-circle pre-check — discard many points immediately
        let dist = hypot(point.x - self.position.x, point.y - self.position.y)
        if dist > radius { return false }
        
        // Check if the scene exists
        guard let sceneNode = self.scene else { return dist <= radius }
        
        // Convert the scene point into the node’s local coordinates
        let localPoint = convert(point, from: sceneNode)
        
        // Check if the local point lies inside the node’s bounding box
        let halfW = size.width * 0.5
        let halfH = size.height * 0.5
        if localPoint.x < -halfW || localPoint.x > halfW || localPoint.y < -halfH || localPoint.y > halfH {
            return false
        }
        
        // If we have cached pixelData: map the local point to image coordinates and check alpha
        if let alpha = alphaAtLocalPoint(localPoint) { return alpha > 0.01 }
        
        // If no pixelData, use a simple circle
        return dist <= radius
    }

    // MARK: - Alpha sampling
    private func alphaAtLocalPoint(_ localPoint: CGPoint) -> CGFloat? {
        guard let pixelData = self.pixelData else { return nil }
        
        // Normalize the local point to [0..1] coordinates (0 = top-left in remapped pixels)
        let nx = (localPoint.x + size.width * 0.5) / size.width
        let ny = (localPoint.y + size.height * 0.5) / size.height
        
        // Check bounds
        if nx < 0 || nx > 1 || ny < 0 || ny > 1 { return 0.0 }
        
        // Map to image pixels (CGImage origin is top-left, while UIKit uses a different Y layout, so adjust accordingly)
        let pxFloat = CGFloat(imgWidth - 1) * nx
        // Y inversion: local y increases upward — when mapping to pixel y we need to flip
        let pyFloat = CGFloat(imgHeight - 1) * (1.0 - ny)
        
        let px = min(max(Int(pxFloat.rounded()), 0), imgWidth - 1)
        let py = min(max(Int(pyFloat.rounded()), 0), imgHeight - 1)
        
        guard let ptr = CFDataGetBytePtr(pixelData) else { return nil }
        
        let offset = py * bytesPerRow + px * bytesPerPixel
        if offset < 0 || offset + bytesPerPixel > CFDataGetLength(pixelData) { return nil }
        
        if bytesPerPixel >= 4 {
            let alphaByte = ptr[offset + alphaChannelOffset]
            return CGFloat(alphaByte) / 255.0
        } else if bytesPerPixel == 3 {
            return 1.0 // no alpha channel — treat as fully opaque
        } else { return nil }
    }
}
