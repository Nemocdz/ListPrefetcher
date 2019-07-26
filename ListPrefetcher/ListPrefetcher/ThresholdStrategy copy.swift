//
//  ThresholdStrategy.swift
//  WGXListPrefetcher
//
//  Created by Nemo on 2019/7/23.
//

import Foundation
import CoreGraphics

/// 阈值策略
public struct ThresholdStrategy {
    let threshold: Double
    var currentPageIndex = 0
    public var totalRowsCount: Int{
         willSet{
             if newValue > totalRowsCount {
                 currentPageIndex += 1
             } else if newValue < totalRowsCount {
                 currentPageIndex = 0
             }
         }
     }
    
    
    /// 设定一个阈值，显示内容达到阈值时进行加载，比较适用于每页数量一致
    /// - Parameter threshold: 阈值
    public init(threshold:Double = 0.7) {
        self.threshold = threshold
        totalRowsCount = 0
    }
}

extension ThresholdStrategy:ListPrefetcherStrategy {
    public func shouldFetch(totalHeight: CGFloat, offsetY: CGFloat) -> Bool {
        let viewRatio = Double(offsetY / totalHeight)
        let perPageCount = Double(totalRowsCount) / Double(currentPageIndex + 1)
        let needRowsCount = perPageCount * (Double(currentPageIndex) + threshold)
        let actalThreshold = needRowsCount / Double(totalRowsCount)
        
        if viewRatio >= actalThreshold {
            return true
        } else {
            return false
        }
    }
}
