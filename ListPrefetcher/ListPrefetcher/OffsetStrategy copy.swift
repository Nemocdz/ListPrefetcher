//
//  OffsetStrategy.swift
//  WGXListPrefetcher
//
//  Created by Nemo on 2019/7/23.
//

import Foundation
import CoreGraphics

/// 除法策略
public struct OffsetStrategy {
    let gap: Int
    let offset: Int
    public var totalRowsCount: Int
    
    /// 根据定义除数和余数，当达到余数时，触发预加载
    /// - Parameter gap: 间隔，除数
    /// - Parameter offset: 偏移，余数
    public init(gap:Int, offset:Int) {
        self.gap = gap
        self.offset = offset
        totalRowsCount = 0
    }
}

extension OffsetStrategy: ListPrefetcherStrategy {
    public func shouldFetch(totalHeight: CGFloat, offsetY: CGFloat) -> Bool {
        let rowHeight = totalHeight / CGFloat(totalRowsCount)
        let actalOffset = totalRowsCount % gap
        let needOffsetY = actalOffset > offset ? totalHeight - CGFloat(actalOffset - offset) * rowHeight : totalHeight - CGFloat(2 * gap + offset) * rowHeight
        if offsetY > needOffsetY {
            return true
        } else {
            return false
        }
    }
}
