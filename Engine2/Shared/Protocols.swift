//
//  Protocols.swift
//  Engine2
//
//  Created by Jairo Bambang Oetomo on 28/03/2019.
//  Copyright © 2019 Jairo Bambang Oetomo. All rights reserved.
//

import MetalKit

protocol Renderable {
    func render(encoder: MTLRenderCommandEncoder)
}


protocol Floating {
    func getRotation(texture: AHNGeneratorBillow, deltaTime: TimeInterval) -> float3
    func getPosition(texture: AHNGeneratorBillow, deltaTime: TimeInterval, throwBack: Bool) -> float3
}

extension Floating where Self: Node {
    func getPosition(texture: AHNGeneratorBillow, deltaTime: TimeInterval, throwBack: Bool) -> float3 {
        
        let posX = position.x
        let posZ = position.z
        let posPoint = CGPoint(
            x: minMax(Double((posX + Float(10)) * Float(Sea.resolution) / Float(20))),
            y: minMax(Double((posZ + Float(10)) * Float(Sea.resolution) / Float(20))))
        
        let varPosition = float3(0,texture.greyscaleValuesAtPositions([posPoint])[0] * Game.hardness * 6,0)
        positions.append(varPosition)
        
        if positions.count > 12 {
            for i in 0...positions.count - 12 {
                positions.remove(at: i)
            }
        }
        
        var running = float3(0)
        
        for pos in positions {
            running.x += pos.x
            running.y += pos.y
            running.z += pos.z
        }
        
        let throwBackZ = max(0, position.y - 0.6) * Float(deltaTime)
        
        if throwBack {
            return float3(position.x + velocity.x * Float(deltaTime), running.y/Float(positions.count), position.z + min(4, velocity.z) * Float(deltaTime) - throwBackZ * 2 )
        } else {
            return float3(position.x + velocity.x * Float(deltaTime), running.y/Float(positions.count), position.z + min(4, velocity.z) * Float(deltaTime))
        }
    }
    
    func getRotation(texture: AHNGeneratorBillow, deltaTime: TimeInterval) -> float3 {
        let posX = position.x
        let posZ = position.z
        let posPointX1 = CGPoint(
            x: minMax(Double((posX + Float(10)) * Float(Sea.resolution) / Float(20) + 10)),
            y: minMax(Double((posZ + Float(10)) * Float(Sea.resolution) / Float(20))))
        
        let posPointX2 = CGPoint(
            x: minMax(Double((posX + Float(10)) * Float(Sea.resolution) / Float(20) - 10)),
            y: minMax(Double((posZ + Float(10)) * Float(Sea.resolution) / Float(20))))
        
        let posPointY1 = CGPoint(
            x: minMax(Double((posX + Float(10)) * Float(Sea.resolution) / Float(20))),
            y: minMax(Double((posZ + Float(10)) * Float(Sea.resolution) / Float(20)) + 10))
        
        let posPointY2 = CGPoint(
            x: minMax(Double((posX + Float(10)) * Float(Sea.resolution) / Float(20))),
            y: minMax(Double((posZ + Float(10)) * Float(Sea.resolution) / Float(20)) - 10))
        
        let dHeightdx = texture.greyscaleValuesAtPositions([posPointX1])[0] -
            texture.greyscaleValuesAtPositions([posPointX2])[0]
        let dHeightdz = texture.greyscaleValuesAtPositions([posPointY1])[0] -
            texture.greyscaleValuesAtPositions([posPointY2])[0]
        var varRotation = float3(0)
        varRotation.x = -Game.hardness * 4 * dHeightdz
        varRotation.z = Game.hardness * 4 * dHeightdx
        
        rotations.append(varRotation)
        
        if rotations.count > 12 {
            for i in 0...rotations.count - 12 {
                rotations.remove(at: i)
            }
        }
        
        var running = float3(0)
        
        for rot in rotations {
            running.x += rot.x
            running.y += rot.y
            running.z += rot.z
        }
        
        return float3(running.x/Float(rotations.count), rotation.y, running.z/Float(rotations.count))
    }
    
    func getSinkRotation(texture: AHNGeneratorBillow, deltaTime: TimeInterval) -> float3 {
        angularVelocity.z -= 0.1 * (rotation.z - Float.pi)
        return float3(rotation.x, rotation.y + 0.01, rotation.z + 0.1 * angularVelocity.z * Float(deltaTime) * -(rotation.z - Float.pi) )
    }
    
    func minMax(_ input: Double) -> Double {
        return max(0, min(Double(Sea.resolution - 10), input))
    }
}
