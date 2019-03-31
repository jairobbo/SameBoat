//
//  Preferences.swift
//  Engine2
//
//  Created by Jairo Bambang Oetomo on 26/03/2019.
//  Copyright © 2019 Jairo Bambang Oetomo. All rights reserved.
//

import MetalKit

class Preferences {
    static let colorPixelFormat: MTLPixelFormat = .bgra8Unorm
    static let depthFormat: MTLPixelFormat = .depth32Float
    static let clearColor: MTLClearColor = MTLClearColorMake(0.7, 0.7, 0.8, 1)
    static let camera = Camera()
    static let initialGameHardness: Float = 0.4
}
