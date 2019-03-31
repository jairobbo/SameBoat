//
//  Engine.swift
//  Engine2
//
//  Created by Jairo Bambang Oetomo on 26/03/2019.
//  Copyright © 2019 Jairo Bambang Oetomo. All rights reserved.
//

import MetalKit

class Engine {
    
    static var device: MTLDevice!
    static var library: MTLLibrary!
    
    static func ignite() {
        Engine.device = MTLCreateSystemDefaultDevice()
    }
}
