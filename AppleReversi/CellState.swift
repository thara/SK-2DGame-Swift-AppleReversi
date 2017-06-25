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
    case Empty = 0, Black, White
    
    /// 相手側の色
    var opponent: CellState {
        switch self {
        case .Black:
            return .White
        case .White:
            return .Black
        default:
            return self
        }
    }
}