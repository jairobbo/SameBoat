//
//  Renderer.swift
//  Engine2
//
//  Created by Jairo Bambang Oetomo on 26/03/2019.
//  Copyright © 2019 Jairo Bambang Oetomo. All rights reserved.
//

import MetalKit
import MetalPerformanceShaders

class Renderer: NSObject, MTKViewDelegate {
    
    static var commandQueue: MTLCommandQueue!
    static var depthStencilState: MTLDepthStencilState!
    static var samplerState: MTLSamplerState!
    static var fps: Int!
    static var uniforms: Uniforms!
    var time: TimeInterval = 0
    static var coinMesh: MTKMesh!
    static var coinPipelineState: MTLRenderPipelineState!
    static var cloudMeshes: [MTKMesh] = []
    static var cloudPipelineState: MTLRenderPipelineState!
    static var lightningMeshes: [MTKMesh] = []
    static var lightningPipelineState: MTLRenderPipelineState!
    
    
    var game: Game!
    
    override init() {
        super.init()
        Engine.ignite()
        Engine.library = Engine.device.makeDefaultLibrary()
        Renderer.commandQueue = Engine.device.makeCommandQueue()
        
        game = Game()
        
        Renderer.coinMesh = try? MTKMesh(mesh: Renderer.loadModel(name: "coin"), device: Engine.device)
        for i in 1...4 {
            let cloudMesh = try? MTKMesh(mesh: Renderer.loadModel(name: "cloud\(i)"), device: Engine.device)
            Renderer.cloudMeshes.append(cloudMesh!)
        }
        for i in 1...6 {
            let lmesh = try? MTKMesh(mesh: Renderer.loadModel(name: "lightning\(i)"), device: Engine.device)
            Renderer.lightningMeshes.append(lmesh!)
        }
        
        createCoinPipelineState()
        createCloudPipelineState()
        createLightningPipelineState()
        
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        Renderer.depthStencilState = Engine.device.makeDepthStencilState(descriptor: depthDescriptor)
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.maxAnisotropy = 2
        Renderer.samplerState = Engine.device.makeSamplerState(descriptor: samplerDescriptor)

        Renderer.uniforms = Uniforms(modelMatrix: matrix_identity_float4x4, viewMatrix: Preferences.camera.viewMatrix, projectionMatrix: Preferences.camera.projectionMatrix)
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        Preferences.camera.aspect = Float(UIScreen.main.bounds.width/UIScreen.main.bounds.height)
    }
    
    func draw(in view: MTKView) {
        
        Renderer.fps = view.preferredFramesPerSecond
        time += Double(1)/Double(view.preferredFramesPerSecond)
        
        
        let buffer = Renderer.commandQueue.makeCommandBuffer()
        let encoder = buffer?.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)
        
        encoder?.setDepthStencilState(Renderer.depthStencilState)
        encoder?.setFragmentSamplerState(Renderer.samplerState, index: 0)
       
        game.render(encoder: encoder!)
        
        encoder?.endEncoding()
        buffer?.present(view.currentDrawable!)
        buffer?.commit()
        
    }
    
    func input(direction: float3) {
        game.boat.velocity =  min(float3(4), game.boat.velocity + direction)
    }
    
    static func loadModel(name: String?) -> MDLMesh {
        let allocator = MTKMeshBufferAllocator(device: Engine.device)
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: MemoryLayout<float3>.stride, bufferIndex: 0)
        vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: MemoryLayout<float3>.stride * 2, bufferIndex: 0)
        vertexDescriptor.attributes[3] = MDLVertexAttribute(name: MDLVertexAttributeOcclusionValue, format: .float3, offset: MemoryLayout<float3>.stride * 2 + MemoryLayout<float2>.stride, bufferIndex: 0)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride * 3 + MemoryLayout<float2>.stride)
        let boatURL = Bundle.main.url(forResource: name, withExtension: "obj")
        let boatAsset = MDLAsset(url: boatURL, vertexDescriptor: vertexDescriptor, bufferAllocator: allocator)
        return boatAsset.object(at: 0) as! MDLMesh
    }
    
    func createCoinPipelineState() {
        let boatVertexFunction = Engine.library.makeFunction(name: "coin_vertex_main")
        let boatFragmentFunction = Engine.library.makeFunction(name: "coin_fragment_main")
        
        let coinDescriptor = MTLRenderPipelineDescriptor()
        coinDescriptor.colorAttachments[0].pixelFormat = Preferences.colorPixelFormat
        coinDescriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        coinDescriptor.fragmentFunction = boatFragmentFunction
        coinDescriptor.vertexFunction = boatVertexFunction
        coinDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(Renderer.coinMesh.vertexDescriptor)
        
        Renderer.coinPipelineState = try! Engine.device.makeRenderPipelineState(descriptor: coinDescriptor)
    }
    
    func createCloudPipelineState() {
        let boatVertexFunction = Engine.library.makeFunction(name: "cloud_vertex_main")
        let boatFragmentFunction = Engine.library.makeFunction(name: "cloud_fragment_main")
        
        let coinDescriptor = MTLRenderPipelineDescriptor()
        coinDescriptor.colorAttachments[0].pixelFormat = Preferences.colorPixelFormat
        coinDescriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        coinDescriptor.fragmentFunction = boatFragmentFunction
        coinDescriptor.vertexFunction = boatVertexFunction
        coinDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(Renderer.coinMesh.vertexDescriptor)
        
        Renderer.cloudPipelineState = try! Engine.device.makeRenderPipelineState(descriptor: coinDescriptor)
    }
    
    func createLightningPipelineState() {
        let lightningVertexFunction = Engine.library.makeFunction(name: "lightning_vertex_main")
        let lightningFragmentFunction = Engine.library.makeFunction(name: "lightning_fragment_main")
        
        let lightningDescriptor = MTLRenderPipelineDescriptor()
        lightningDescriptor.colorAttachments[0].pixelFormat = Preferences.colorPixelFormat
        lightningDescriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        lightningDescriptor.fragmentFunction = lightningFragmentFunction
        lightningDescriptor.vertexFunction = lightningVertexFunction
        lightningDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(Renderer.lightningMeshes[0].vertexDescriptor)
        
        Renderer.lightningPipelineState = try! Engine.device.makeRenderPipelineState(descriptor: lightningDescriptor)
    }
}


struct Uniforms {
    var modelMatrix: float4x4
    var viewMatrix: float4x4
    var projectionMatrix: float4x4
}
