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
    
//    var cpu: ComputerPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Viewの設定
        let skView = self.view as! SKView
        skView.isMultipleTouchEnabled = false
        self.scene = GameScene()
        self.scene.size = CGSize(width: 375, height: 667)
        self.scene.scaleMode = .aspectFit
        skView.presentScene(self.scene)
        
        self.scene.switchTurnHandler = self.switchTurn
    }
    
    func switchTurn() {
        if self.scene.nextColor == self.scene.cpu {
            self.scene.isUserInteractionEnabled = false
            Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(makeMoveByComputer), userInfo: nil, repeats: false)
        }
    }
    
    /// コンピュータプレイヤーに一手打たせる
    func makeMoveByComputer() {
        let next = self.scene.strategist?.bestMove(for: self.scene.board.currentPlayer!)
        //let nextMove = self.cpu.selectMove(self.scene.board!)
        self.scene.makeMove(next as? Move)
        
        // プレイヤーが合法な手を打てない場合は、プレイヤーのターンをスキップする
        if self.scene.board.hasGameFinished() == false && self.scene.board.existsValidMove(self.scene.cpu.opponent) == false {
            self.makeMoveByComputer()
        }
        self.scene.board.currentPlayer = self.scene.board.currentPlayer?.opponent
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
