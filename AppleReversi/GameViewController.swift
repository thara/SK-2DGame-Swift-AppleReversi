//
//  GameViewController.swift
//  AppleReversi
//
//  Created by 原知愛 on 2016/05/23.
//  Copyright (c) 2016年 Tomochika Hara. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Viewの設定
        let skView = self.view as! SKView
        skView.isMultipleTouchEnabled = false
        self.scene = GameScene()
        self.scene.size = CGSize(width: 375, height: 667)
        self.scene.scaleMode = .aspectFit
        skView.presentScene(self.scene)
        
        self.scene.switchCPUTurnHandler = self.switchCPUTurn
    }
    
    func switchCPUTurn() {
        self.scene.isUserInteractionEnabled = false
        Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(makeMoveByCPU), userInfo: nil, repeats: false)
    }
    
    func makeMoveByCPU() {
        self.scene.makeMoveByCPU()
        self.scene.isUserInteractionEnabled = true
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
