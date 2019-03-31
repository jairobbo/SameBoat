import MetalKit

class Lightning: Node, Renderable, Equatable {
    
    var index: Int {
        return Int(arc4random_uniform(6))
    }
    var strikes: Int = 0
    
    override init() {
        super.init()
    }
    
    func render(encoder: MTLRenderCommandEncoder) {
        
        if strikes > 0 {
            
            position = float3(parent!.position.x, parent!.position.y - 0.7, parent!.position.z)
            
            Renderer.uniforms.modelMatrix = float4x4(translation: position) * float4x4(rotation: parent!.rotation)
            encoder.setRenderPipelineState(Renderer.lightningPipelineState)
            encoder.setVertexBuffer(Renderer.lightningMeshes[index].vertexBuffers[0].buffer, offset: 0, index: 0)
            encoder.setVertexBytes(&Renderer.uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
            guard let lightningSubmesh = Renderer.lightningMeshes[index].submeshes.first else { return }
            encoder.drawIndexedPrimitives(type: lightningSubmesh.primitiveType, indexCount: lightningSubmesh.indexCount, indexType: lightningSubmesh.indexType, indexBuffer: lightningSubmesh.indexBuffer.buffer, indexBufferOffset: lightningSubmesh.indexBuffer.offset)
            
            strikes -= 1
        }
    }
    
    static func == (lhs: Lightning, rhs: Lightning) -> Bool {
        return lhs.position.x == rhs.position.x
    }
}
