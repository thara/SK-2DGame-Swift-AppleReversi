//
//  Player.swift
//  AppleReversi
//
//  Created by Tomochika Hara on 2017/08/28.
//  Copyright © 2017年 Tomochika Hara. All rights reserved.
//

import Foundation
import GameplayKit


class Player : NSObject, GKGameModelPlayer {
    let playerId: Int
    let color: CellState
    
    var opponent : Player {
        switch self.color {
        case .black:
            return Player.whitePlayer
        case .white:
            return Player.blackPlayer
        default:
            return self
        }
    }
    
    init(color: CellState) {
        self.playerId = color.rawValue
        self.color = color
    }
    
    static let allPlayers: [Player] = [blackPlayer, whitePlayer]
    
    static let blackPlayer : Player = Player(color: .black)
    static let whitePlayer : Player = Player(color: .white)
}
