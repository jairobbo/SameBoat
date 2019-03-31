//
//  Coin.swift
//  Engine2
//
//  Created by Jairo Bambang Oetomo on 28/03/2019.
//  Copyright © 2019 Jairo Bambang Oetomo. All rights reserved.
//

import MetalKit

class Coin: Node, Renderable, Floating, Equatable {
   
    let mesh = Renderer.coinMesh
    var isFound: Bool = false
    
    override init() {
        super.init()
    }
    
    func render(encoder: MTLRenderCommandEncoder) {
        time += Double(1)/Double(Renderer.fps)
        
        Renderer.uniforms.modelMatrix = matrix_identity_float4x4
        
        position.y = isFound ? position.y + 0.1 : getPosition(texture: Sea.waveNoise, deltaTime: Double(1)/Double(Renderer.fps), throwBack: false).y + 0.2
        scale = float3(0.6)
        position.z -= isFound ? 0 : 0.1
        
        rotation.y = (isFound ? 24 : 6) * Float(time)
        
        Renderer.uniforms.modelMatrix = float4x4(translation: position) * float4x4(rotation: rotation) * float4x4(scaling: scale)
        
        encoder.setRenderPipelineState(Renderer.coinPipelineState)
        encoder.setVertexBuffer(Renderer.coinMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        encoder.setVertexBytes(&Renderer.uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        guard let coinSubmesh = Renderer.coinMesh.submeshes.first else { return }
        encoder.drawIndexedPrimitives(type: coinSubmesh.primitiveType, indexCount: coinSubmesh.indexCount, indexType: coinSubmesh.indexType, indexBuffer: coinSubmesh.indexBuffer.buffer, indexBufferOffset: coinSubmesh.indexBuffer.offset)
    }
    
    static func == (lhs: Coin, rhs: Coin) -> Bool {
        return lhs.position.x == rhs.position.x &&
            lhs.position.y == rhs.position.y
    }
}
