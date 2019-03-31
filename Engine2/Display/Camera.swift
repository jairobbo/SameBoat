//
//  Camera.swift
//  Engine2
//
//  Created by Jairo Bambang Oetomo on 26/03/2019.
//  Copyright © 2019 Jairo Bambang Oetomo. All rights reserved.
//

import UIKit
import simd

class Camera: Node {
    
    override init() {
        aspect =  Float(UIScreen.main.bounds.width/UIScreen.main.bounds.height)
        super.init()
        position = float3(0,3,-10)
    }
    
    var fovDegrees: Float = 90
    var fovRadians: Float {
        return radians(fromDegrees: fovDegrees)
    }
    var aspect: Float
    var near: Float = 0.001
    var far: Float = 100
    
    
    var projectionMatrix: float4x4 {
        return float4x4(projectionFov: fovRadians,
                        near: near,
                        far: far,
                        aspect: aspect)
    }
    
    var viewMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotateMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return (translateMatrix * scaleMatrix * rotateMatrix).inverse
    }
    
}
