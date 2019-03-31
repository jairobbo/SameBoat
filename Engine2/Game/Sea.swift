//
//  Sea.swift
//  Engine2
//
//  Created by Jairo Bambang Oetomo on 29/03/2019.
//  Copyright © 2019 Jairo Bambang Oetomo. All rights reserved.
//

import MetalKit

class Sea: Node, Renderable {
    
    var lines: AHNGeneratorWave!
    var seaMesh: MTKMesh!
    static var waveNoise: AHNGeneratorBillow!
    static var pipelineState: MTLRenderPipelineState!
    static let resolution: Int = 512
    
    static var zValue: Float = 0.001
    static var yValue: Float = 0.002
    static var height: Float = 3
    
    override init() {
        super.init()
        let allocator = MTKMeshBufferAllocator(device: Engine.device)
        let planeModel = MDLMesh(planeWithExtent: float3(20,1,20), segments: uint2(200,200), geometryType: .triangles, allocator: allocator)
        seaMesh = try? MTKMesh(mesh: planeModel, device: Engine.device)
        
        createPipelineState()
        
        Sea.waveNoise = AHNGeneratorBillow()
        Sea.waveNoise.yValue = Float(arc4random_uniform(100) + 1)
        Sea.waveNoise.textureWidth = Sea.resolution
        Sea.waveNoise.textureHeight = Sea.resolution
        
        lines = AHNGeneratorWave()
        lines.textureWidth = 256
        lines.textureHeight = 256
        lines.frequency = 10
        lines.yoffsetInput = Sea.waveNoise
    }
    
    func render(encoder: MTLRenderCommandEncoder) {
        Sea.waveNoise.zValue += Sea.zValue
        Sea.waveNoise.yValue += Sea.yValue
        
        Renderer.uniforms.modelMatrix = modelMatrix
        
        encoder.setRenderPipelineState(Sea.pipelineState)
        encoder.setVertexBuffer(seaMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        encoder.setVertexTexture(Sea.waveNoise.texture(), index: 0)
        encoder.setVertexBytes(&Renderer.uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        encoder.setVertexBytes(&Sea.height, length: MemoryLayout<Float>.stride, index: 2)
        encoder.setFragmentTexture(lines.texture(), index: 0)
        encoder.setFragmentTexture(Sea.waveNoise.texture(), index: 1)
        guard let submesh = seaMesh.submeshes.first else { return }
        encoder.drawIndexedPrimitives(type: MTLPrimitiveType.triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
    }
    
    func createPipelineState() {
        let vertexFunction = Engine.library.makeFunction(name: "vertex_main")
        let fragmentFunction = Engine.library.makeFunction(name: "fragment_main")
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = Preferences.colorPixelFormat
        descriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        descriptor.fragmentFunction = fragmentFunction
        descriptor.vertexFunction = vertexFunction
        descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(seaMesh.vertexDescriptor)
        
        Sea.pipelineState = try? Engine.device.makeRenderPipelineState(descriptor: descriptor)
    }
}
