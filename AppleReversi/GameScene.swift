//
//  GameScene.swift
//  AppleReversi
//
//  Created by 原知愛 on 2016/05/23.
//  Copyright (c) 2016年 Tomochika Hara. All rights reserved.
//

import SpriteKit
import GameplayKit

/// マス目のサイズ
let SquareHeight: CGFloat = 45.0
let SquareWidth: CGFloat = 45.0

/// 画面中心と盤面の中心位置のy軸方向のズレ
let CentralDeltaY: CGFloat = 10.0

/// 石のイメージファイルの名前
let DiskImageNames = [
    CellState.black : "black",
    CellState.white : "white",
]


class GameScene: SKScene {
    
    let gameLayer = SKNode()
    let disksLayer = SKNode()
    
    var diskNodes = Array2D<SKSpriteNode>(rows: BoardSize, columns: BoardSize)
    var board: Board!
    var nextColor: CellState!
    
    let blackScoreLabel = SKLabelNode.createScoreLabel(x: 150, y: -260)
    let whiteScoreLabel = SKLabelNode.createScoreLabel(x: 150, y: -310)
    
    let cpu : CellState = .white
    
    var gameResultLayer: SKNode?
    
    var switchTurnHandler: (() -> ())?
    
    var strategist: GKMinmaxStrategist?
    
    override func didMove(to view: SKView) {
        // 基準点を中心に設定
        super.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // 背景の設定
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        self.addChild(background)
        self.addChild(self.gameLayer)
        
        // anchorPointからの相対位置
        let layerPosition = CGPoint(
            x: -SquareWidth * CGFloat(BoardSize) / 2,
            y: -SquareHeight * CGFloat(BoardSize) / 2 + CentralDeltaY
        )
        
        self.gameLayer.addChild(self.blackScoreLabel)
        self.gameLayer.addChild(self.whiteScoreLabel)
        
        self.disksLayer.position = layerPosition
        self.gameLayer.addChild(self.disksLayer)
        
        self.strategist = GKMinmaxStrategist()
        self.strategist?.maxLookAheadDepth = 3
        self.strategist?.randomSource = GKARC4RandomSource()
        
        self.initBoard()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self.disksLayer)
        
        if let (row, column) = self.convertPointOnBoard(location) {
            // タップされた場所に現在のターンの石を配置する手
            let move = Move(color: self.nextColor, row: row, column: column)
            
            if move.canPlace(self.board.cells) {
                self.makeMove(move)
                if self.board.hasGameFinished() == false {
                    self.board.currentPlayer = self.board.currentPlayer?.opponent
                    self.switchTurnHandler?()
                }
            }
        }
    }
    
    /// 盤の初期化
    func initBoard() {
        var cells = Array2D<CellState>(rows: BoardSize, columns: BoardSize, repeatedValue: .empty)
        cells[3, 4] = .black
        cells[4, 3] = .black
        cells[3, 3] = .white
        cells[4, 4] = .white
        
        self.board = Board(cells: cells)
        self.updateDiskNodes()
        self.nextColor = .black
        
        self.strategist?.gameModel = self.board
        self.board.currentPlayer = Player.blackPlayer
    }
    
    /// 手を打つ
    func makeMove(_ move: Move?) {
        if move != nil {
            // 盤上に手を打つ
            self.board.makeMove(move!)
        }
        // 今打った手とは反対の色にターンを変える
        self.nextColor = self.nextColor.opponent
        // 今打った石と返された石を画面上に表示
        self.updateDiskNodes()
        if self.board.hasGameFinished() {
            // ゲーム終了時
            self.showGameResult()
        }
    }
    
    func updateDiskNodes() {
        for row in 0..<BoardSize {
            for column in 0..<BoardSize {
                if let state = self.board.cells[row, column] {
                    
                    if let imageName = DiskImageNames[state] {
                        if let prevNode = self.diskNodes[row, column] {
                            if prevNode.userData?["state"] as! Int == state.rawValue {
                                // 変化が無いセルはスキップする
                                continue
                            }
                            // 古いノードを削除
                            prevNode.removeFromParent()
                        }
                        
                        // 新しいノードをレイヤーに追加
                        let newNode = SKSpriteNode(imageNamed: imageName)
                        newNode.userData = ["state" : state.rawValue] as NSMutableDictionary
                        
                        newNode.size = CGSize(width: SquareWidth, height: SquareHeight)
                        newNode.position = self.convertPointOnLayer(row, column: column)
                        self.disksLayer.addChild(newNode)
                        
                        self.diskNodes[row, column] = newNode
                    }
                }
            }
        }
        // スコア表示の更新
        self.updateScores()
    }
    
    /// ゲームをリスタートする
    func restartGame() {
        for row in 0..<BoardSize {
            for column in 0..<BoardSize {
                if let diskNode = self.diskNodes[row, column] {
                    diskNode.removeFromParent()
                    self.diskNodes[row, column] = nil
                }
            }
        }
        self.initBoard()
    }
    
    /// 盤上での座標をレイヤー上での座標に変換する
    func convertPointOnLayer(_ row: Int, column: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * SquareWidth + SquareWidth / 2,
            y: CGFloat(row) * SquareHeight + SquareHeight / 2
        )
    }
    
    /// レイヤー上での座標を盤上での座標に変換する
    func convertPointOnBoard(_ point: CGPoint) -> (row: Int, column: Int)? {
        if 0 <= point.x && point.x < SquareWidth * CGFloat(BoardSize) &&
            0 <= point.y && point.y < SquareHeight * CGFloat(BoardSize) {
            return (Int(point.y / SquareHeight), Int(point.x / SquareWidth))
        } else {
            return nil
        }
    }
    
    /// スコアを更新する
    func updateScores() {
        self.blackScoreLabel.text = String(self.board.countCells(.black))
        self.whiteScoreLabel.text = String(self.board.countCells(.white))
    }
    
    /// リザルト画面を表示する
    func showGameResult() {
        let black = self.board.countCells(.black)
        let white = self.board.countCells(.white)
        // 勝敗に対応した画像を読み込んだノード
        var resultImage: SKSpriteNode
        if white < black {
            resultImage = SKSpriteNode(imageNamed: "win_black")
        } else if (black < white) {
            resultImage = SKSpriteNode(imageNamed: "win_white")
        } else {
            resultImage = SKSpriteNode(imageNamed: "draw")
        }
        // 画像の縦幅の調整
        let sizeRatio = self.size.width / resultImage.size.width
        let imageHeight = resultImage.size.height * sizeRatio
        resultImage.size = CGSize(width: self.size.width, height: imageHeight)
        
        let gameResultLayer = GameResultLayer()
        gameResultLayer.isUserInteractionEnabled = true
        gameResultLayer.touchHandler = self.hideGameResult
        gameResultLayer.addChild(resultImage)
        
        self.gameResultLayer = gameResultLayer
        self.addChild(self.gameResultLayer!)
    }
    
    /// リザルト画面を非表示にする
    func hideGameResult() {
        self.gameResultLayer?.removeFromParent()
        self.gameResultLayer = nil
        self.restartGame()
    }
}

extension SKLabelNode {
    /// スコア表示用のSKLabelNodeを生成する
    class func createScoreLabel(x: Int, y: Int) -> SKLabelNode {
        let node = SKLabelNode(fontNamed: "Zapfino")
        node.position = CGPoint(x: x, y: y)
        node.fontSize = 25
        node.horizontalAlignmentMode = .right
        node.fontColor = UIColor.white
        return node
    }
}

/// ゲームリザルト用ノード
class GameResultLayer: SKNode {
    
    var touchHandler: (() -> ())?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchHandler?()
    }
}
