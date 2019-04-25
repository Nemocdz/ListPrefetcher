//
//  ListPrefetcher.swift
//  ListPrefetcher
//
//  Created by Nemo on 2019/1/30.
//  Copyright © 2019 nemocdz. All rights reserved.
//

import UIKit

class ListPrefetcher:NSObject{
    @objc let scrollView:UIScrollView
    var contentSizeObserver:NSKeyValueObservation?
    var contentOffsetObserver:NSKeyValueObservation?
    weak var delegate: ListPrefetcherDelegate?
    var strategy: ListPrefetcherStrategy
    
    public func start() {
        contentSizeObserver = observe(\.scrollView.contentSize) { object, _ in
            guard let delegate = object.delegate else { return }
            object.strategy.totalRowsCount = delegate.totalRowsCount
        }
        
        contentOffsetObserver = observe(\.scrollView.contentOffset) { object, _ in
            let offsetY = object.scrollView.contentOffset.y + object.scrollView.frame.height
            let totalHeight = object.scrollView.contentSize.height
            guard offsetY < totalHeight else { return }
            if object.strategy.shouldFetch(totalHeight, offsetY) {
                object.delegate?.startFetch()
            }
        }
    }
    
    public func stop() {
        contentSizeObserver?.invalidate()
        contentOffsetObserver?.invalidate()
    }
    
    public init(strategy:ListPrefetcherStrategy, scrollView:UIScrollView) {
        self.strategy = strategy
        self.scrollView = scrollView
        super.init()
    }
}

protocol ListPrefetcherDelegate:AnyObject {
    var totalRowsCount:Int { get }
    func startFetch()
}

protocol ListPrefetcherStrategy {
    var totalRowsCount:Int { get set }
    func shouldFetch(_ totalHeight:CGFloat, _ offsetY:CGFloat) -> Bool
}

struct RemainStrategy: ListPrefetcherStrategy{
    func shouldFetch(_ totalHeight: CGFloat, _ offsetY: CGFloat) -> Bool {
        let rowHeight = totalHeight / CGFloat(totalRowsCount)
        let needOffsetY = rowHeight * CGFloat(totalRowsCount - remainRowsCount)
        if offsetY > needOffsetY {
            return true
        } else {
            return false
        }
    }
    
    var totalRowsCount: Int
    let remainRowsCount: Int
    
    
    init(remainRowsCount:Int = 1) {
        self.remainRowsCount = remainRowsCount
        totalRowsCount = 0
    }
}


struct OffsetStrategy: ListPrefetcherStrategy {
    func shouldFetch(_ totalHeight: CGFloat, _ offsetY: CGFloat) -> Bool {
        let rowHeight = totalHeight / CGFloat(totalRowsCount)
        let actalOffset = totalRowsCount % gap
        let needOffsetY = actalOffset > offset ? totalHeight - CGFloat(actalOffset - offset) * rowHeight : totalHeight - CGFloat(2 * gap + offset) * rowHeight
        if offsetY > needOffsetY {
            return true
        } else {
            return false
        }
    }
    
    var totalRowsCount: Int
    let gap: Int
    let offset: Int
    
    init(gap:Int, offset:Int) {
        self.gap = gap
        self.offset = offset
        totalRowsCount = 0
    }
}

struct ThresholdStrategy: ListPrefetcherStrategy{
    func shouldFetch(_ totalHeight: CGFloat, _ offsetY: CGFloat) -> Bool {
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
    
    var totalRowsCount: Int{
        willSet{
            if newValue > totalRowsCount {
                currentPageIndex += 1
            } else if newValue < totalRowsCount {
                currentPageIndex = 0
            }
        }
    }
    
    let threshold: Double
    var currentPageIndex = 0
    
    public init(threshold:Double = 0.7) {
        self.threshold = threshold
        totalRowsCount = 0
    }
}




