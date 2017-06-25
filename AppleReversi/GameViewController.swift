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

    fileprivate var scene: GameScene!
    
    var cpu: ComputerPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Viewの設定
        let skView = self.view as! SKView
        skView.isMultipleTouchEnabled = false
        self.scene = GameScene()
        self.scene.size = CGSize(width: 375, height: 667)
        self.scene.scaleMode = .aspectFit
        skView.presentScene(self.scene)
        
        let evaluate = countColor
        let maxDepth = 2
        let search = MiniMaxMethod(evaluate: evaluate, maxDepth: maxDepth)
        self.cpu = ComputerPlayer(color: .white, search: search)
        
        self.scene.switchTurnHandler = self.switchTurn
        self.scene.initBoard()
    }
    
    func switchTurn() {
        if self.scene.nextColor == self.cpu.color {
            self.scene.isUserInteractionEnabled = false
            Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(makeMoveByComputer), userInfo: nil, repeats: false)
        }
    }
    
    /// コンピュータプレイヤーに一手打たせる
    func makeMoveByComputer() {
        let nextMove = self.cpu.selectMove(self.scene.board!)
        self.scene.makeMove(nextMove)
        
        // プレイヤーが合法な手を打てない場合は、プレイヤーのターンをスキップする
        if self.scene.board.hasGameFinished() == false && self.scene.board.existsValidMove(self.cpu.color.opponent) == false {
            self.makeMoveByComputer()
        }
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
