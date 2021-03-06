//
//  CellState.swift
//  AppleReversi
//
//  Created by Tomochika Hara on 2016/05/23.
//  Copyright © 2016年 Tomochika Hara. All rights reserved.
//

import Foundation

/// 盤上の一セルの状態
public enum CellState: Int {
    case empty = 0, black, white
    
    /// 相手側の色
    var opponent: CellState {
        switch self {
        case .black:
            return .white
        case .white:
            return .black
        default:
            return self
        }
    }
}
