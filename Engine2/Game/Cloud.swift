import MetalKit

class Cloud: Node, Renderable, Floating, Equatable {
    
    var index: Int = 0
    static var cloudSpeed: Float = 0.03
    var thunder: Bool = true {
        didSet {
            if thunder {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.thunder = false
                }
            }
        }
    }
    
    override init() {
        super.init()
        let lightning = Lightning()
        lightning.parent = self
        children.append(lightning)
    }
    
    func render(encoder: MTLRenderCommandEncoder) {
        time += Double(1)/Double(Renderer.fps)
        
        
        Renderer.uniforms.modelMatrix = matrix_identity_float4x4
        position.z -= Cloud.cloudSpeed
        
        
        for child in children {
            let picknumber = Int(arc4random_uniform(750))
            if picknumber == 0 {
                let strikes = Int(arc4random_uniform(6) + 1)
                (child as! Lightning).strikes = strikes
                if !Boat.isSinking{
                    Game.adjustHardness(amount: Float(strikes)/50)
                }
            }
            (child as! Renderable).render(encoder: encoder)
        }
        
        Renderer.uniforms.modelMatrix = float4x4(translation: position) * float4x4(rotation: rotation)
         encoder.setRenderPipelineState(Renderer.cloudPipelineState)
        encoder.setVertexBuffer(Renderer.cloudMeshes[index].vertexBuffers[0].buffer, offset: 0, index: 0)
        encoder.setVertexBytes(&Renderer.uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        guard let coinSubmesh = Renderer.cloudMeshes[index].submeshes.first else { return }
        encoder.drawIndexedPrimitives(type: coinSubmesh.primitiveType, indexCount: coinSubmesh.indexCount, indexType: coinSubmesh.indexType, indexBuffer: coinSubmesh.indexBuffer.buffer, indexBufferOffset: coinSubmesh.indexBuffer.offset)
    }
    
    static func == (lhs: Cloud, rhs: Cloud) -> Bool {
        return lhs.position.x == rhs.position.x
    }
}
