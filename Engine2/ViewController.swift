//
//  ViewController.swift
//  Engine2
//
//  Created by Jairo Bambang Oetomo on 26/03/2019.
//  Copyright © 2019 Jairo Bambang Oetomo. All rights reserved.
//

import MetalKit
import CoreImage

class ViewController: UIViewController {

    var renderer = Renderer()
    @IBOutlet weak var mtkView: MTKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mtkView.colorPixelFormat = Preferences.colorPixelFormat
        mtkView.depthStencilPixelFormat = Preferences.depthFormat
        mtkView.clearColor = Preferences.clearColor
        mtkView.isOpaque = false
        mtkView.delegate = renderer
        mtkView.device = Engine.device
        
        let pangesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(gesture:)))
        mtkView.addGestureRecognizer(pangesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(gesture:)))
        mtkView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didPan(gesture: UIPanGestureRecognizer) {
        if !Boat.isSinking{
            renderer.input(direction: float3(Float(gesture.translation(in: gesture.view!).x/50), 0, -Float(gesture.translation(in: gesture.view!).y/50)))
            gesture.setTranslation(.zero, in: gesture.view)
        }
    }
    
    @objc func didTap(gesture: UITapGestureRecognizer) {
        if Boat.isSinking {
            Boat.isSinking = false
            renderer.game.boat.position = float3(0)
            renderer.game.boat.velocity = float3(0)
            Game.adjustHardness(amount: Preferences.initialGameHardness - Game.hardness)
        }
    }

}

