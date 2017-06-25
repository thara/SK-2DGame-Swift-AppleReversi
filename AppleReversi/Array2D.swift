//
//  Array2D.swift
//  AppleReversi
//
//  Created by Tomochika Hara on 2016/05/23.
//  Copyright © 2016年 Tomochika Hara. All rights reserved.
//

import Foundation

/// 2次元配列
struct Array2D<T> {
    
    let rows: Int
    let columns: Int
    
    private var array: [T?]
    
    init(rows: Int, columns: Int, repeatedValue: T? = nil) {
        self.rows = rows
        self.columns = columns
        self.array = Array<T?>(count: rows * columns, repeatedValue: repeatedValue)
    }
    
    subscript(row: Int, column: Int) -> T? {
        get {
            if row < 0 || self.rows <= row || column < 0 || self.columns <= column {
                return nil
            }
            let idx = row * self.columns + column
            return array[idx]
        }
        set {
            self.array[row * self.columns + column] = newValue
        }
    }
}