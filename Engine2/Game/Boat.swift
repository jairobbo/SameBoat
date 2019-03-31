//
//  Boat.swift
//  Engine2
//
//  Created by Jairo Bambang Oetomo on 28/03/2019.
//  Copyright © 2019 Jairo Bambang Oetomo. All rights reserved.
//

import MetalKit

class Boat: Node, Renderable, Floating {
    
    var boatMesh: MTKMesh!
    var boatAngularVelocityY: Float = 0
    static var isSinking: Bool = false
    static var boatPipelineState: MTLRenderPipelineState!
    static var texture: MTLTexture!
    
    override init() {
        super.init()
        
        let boatMDL = Renderer.loadModel(name: "boat1")
        print(boatMDL.generateAmbientOcclusionVertexColors(withQuality: 1, attenuationFactor: 1, objectsToConsider: [], vertexAttributeNamed: MDLVertexAttributeOcclusionValue))
        
        boatMesh = try? MTKMesh(mesh: boatMDL, device: Engine.device)        
        
        let boatVertexFunction = Engine.library.makeFunction(name: "boat_vertex_main")
        let boatFragmentFunction = Engine.library.makeFunction(name: "boat_fragment_main")
        
        let boatDescriptor = MTLRenderPipelineDescriptor()
        boatDescriptor.colorAttachments[0].pixelFormat = Preferences.colorPixelFormat
        boatDescriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        boatDescriptor.fragmentFunction = boatFragmentFunction
        boatDescriptor.vertexFunction = boatVertexFunction
        boatDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(boatMesh.vertexDescriptor)
        
        Boat.boatPipelineState = try? Engine.device.makeRenderPipelineState(descriptor: boatDescriptor)
        
        let textureLoader = MTKTextureLoader(device: Engine.device)
        Boat.texture = try? textureLoader.newTexture(name: "boatTexture", scaleFactor: 2, bundle: nil, options:  [.SRGB: false])
    }
    
    func render(encoder: MTLRenderCommandEncoder) {
        
        velocity.z -= 0.01
        
        position = getPosition(texture: Sea.waveNoise, deltaTime: Double(1)/Double(Renderer.fps), throwBack: true)
        
        if Boat.isSinking {
            rotation = getSinkRotation(texture: Sea.waveNoise, deltaTime: Double(1)/Double(Renderer.fps))
            velocity.x = -0.1 * position.x
            velocity.z = -0.1 * position.z
        } else {
            rotation = getRotation(texture: Sea.waveNoise, deltaTime: Double(1)/Double(Renderer.fps))
        }
        
        boatAngularVelocityY = velocity.x  - rotation.y
        rotation.y += boatAngularVelocityY * Float(1)/Float(Renderer.fps) - rotation.y * 0.01
        
        Renderer.uniforms.modelMatrix = float4x4(translation: position) * float4x4(rotation: rotation)
        
        encoder.setRenderPipelineState(Boat.boatPipelineState)
        for (i, buffer) in boatMesh.vertexBuffers.enumerated() {
            encoder.setVertexBuffer(buffer.buffer, offset: 0, index: i)
            encoder.setVertexBytes(&Renderer.uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
            encoder.setFragmentTexture(Boat.texture, index: 0)
            let boatSubmesh = boatMesh.submeshes[i] 
            encoder.drawIndexedPrimitives(type: boatSubmesh.primitiveType, indexCount: boatSubmesh.indexCount, indexType: boatSubmesh.indexType, indexBuffer: boatSubmesh.indexBuffer.buffer, indexBufferOffset: boatSubmesh.indexBuffer.offset)
        }
        
    }
    
    
}
