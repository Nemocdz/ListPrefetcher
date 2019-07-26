//
//  RemainStrategy.swift
//  WGXListPrefetcher
//
//  Created by Nemo on 2019/7/23.
//

import Foundation
import CoreGraphics

/// 剩余数量策略
public struct RemainStrategy {
    let remainRowsCount: Int
    public var totalRowsCount: Int
    
    
    /// 设置剩余多少触发预加载
    /// - Parameter remainRowsCount: 剩余数量
    public init(remainRowsCount:Int = 1) {
        self.remainRowsCount = remainRowsCount
        totalRowsCount = 0
    }
}

extension RemainStrategy: ListPrefetcherStrategy {
    public func shouldFetch(totalHeight: CGFloat, offsetY: CGFloat) -> Bool {
        let rowHeight = totalHeight / CGFloat(totalRowsCount)
        let needOffsetY = rowHeight * CGFloat(totalRowsCount - remainRowsCount)
        if offsetY > needOffsetY {
            return true
        } else {
            return false
        }
    }
}
