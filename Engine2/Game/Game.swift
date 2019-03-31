//
//  Game.swift
//  Engine2
//
//  Created by Jairo Bambang Oetomo on 29/03/2019.
//  Copyright © 2019 Jairo Bambang Oetomo. All rights reserved.
//

import MetalKit

class Game: Renderable {
    var impact = UIImpactFeedbackGenerator()
    var boat: Boat!
    var sea: Sea!
    var clouds: [Cloud] = []
    var coins: [Coin] = []
    static var hardness: Float = Preferences.initialGameHardness {
        didSet {
            if hardness > 0.8 {
                Boat.isSinking = true
                Game.adjustHardness(amount: -Game.hardness)
            }
            Sea.height = hardness * Float(6)
            Sea.yValue = hardness * 0.004
            Sea.zValue = hardness * 0.002
        }
    }
    static var targetHardness: Float = Preferences.initialGameHardness
    static var hardnessTimer: Timer?
    
    init() {
        sea = Sea()
        boat = Boat()
        Game.hardness = Preferences.initialGameHardness
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (timer) in
            if !Boat.isSinking {
                let coin = Coin()
                coin.position.z = 10
                coin.position.x = Float(Double(arc4random_uniform(4)) - 1.5)
                self.coins.append(coin)
            }
            }.fire()
        
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (timer) in
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(arc4random_uniform(10)), execute: {
                let cloud = Cloud()
                cloud.index = Int(arc4random_uniform(4))
                cloud.position.z = 20
                cloud.position.y = 5
                cloud.position.x = Float(Double(arc4random_uniform(6)) - 2.5)
                self.clouds.append(cloud)
            })
            }.fire()
    }
    
    func render(encoder: MTLRenderCommandEncoder) {
        
        sea.render(encoder: encoder)
        boat.render(encoder: encoder)
        
        if !Boat.isSinking {
            for coin in coins {
                coin.render(encoder: encoder)
                if intersects(coin.position, boat.position) {
                    if !coin.isFound {
                        coin.isFound = true
                        Game.adjustHardness(amount: -0.1)
                        impact.impactOccurred()
                    }
                }
                if coin.position.z < -9 {
                    coins.remove(at: coins.firstIndex(of: coin)!)
                }
                if coin.position.y > 10 {
                    coins.remove(at: coins.firstIndex(of: coin)!)
                }
            }
        }
        
        for cloud in clouds {
            cloud.render(encoder: encoder)
            if cloud.position.z < -20 {
                clouds.remove(at: clouds.firstIndex(of: cloud)!)
            }
        }
        
        if boat.position.z > 9 || boat.position.z < -9 ||
            boat.position.x < -5 || boat.position.x > 5 {
            if !Boat.isSinking {
                Boat.isSinking = true
                Game.adjustHardness(amount: -Game.hardness)
            }
        }
    }
    
    func intersects(_ first: float3, _ second: float3) -> Bool {
        return abs(second.x - first.x) < 0.3 &&
            abs(second.z - first.z) < 0.3
    }
    
    static func adjustHardness(amount: Float) {
        Game.hardnessTimer?.invalidate()
        Game.targetHardness += amount
        let increment = (Game.targetHardness - Game.hardness) / (5 * 60)
        Game.hardnessTimer = Timer.scheduledTimer(withTimeInterval: Double(1)/Double(Renderer.fps), repeats: true) { (timer) in
            if (increment > 0 && Game.hardness >= Game.targetHardness) || (increment < 0 && Game.hardness <= Game.targetHardness) {
                timer.invalidate()
            } else {
                Game.hardness += increment
            }
        }
    }
}
