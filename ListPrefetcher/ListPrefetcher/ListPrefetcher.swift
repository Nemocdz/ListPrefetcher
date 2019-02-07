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
        contentSizeObserver = observe(\.scrollView.contentSize) { (_, _) in
            guard let delegate = self.delegate else { return }
            self.strategy.totalRowsCount = delegate.totalRowsCount()
        }
        
        contentOffsetObserver = observe(\.scrollView.contentOffset){ (_, _) in
            guard self.scrollView.contentOffset.y + self.scrollView.frame.height < self.scrollView.contentSize.height else { return }
            if self.strategy.shouldFetch(self.scrollView) {
                self.delegate?.startFetch()
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
    }
}

protocol ListPrefetcherDelegate:AnyObject {
    func totalRowsCount() -> Int
    func startFetch()
}

protocol ListPrefetcherStrategy {
    var totalRowsCount: Int { get set }
    func shouldFetch(_ scrollView: UIScrollView) -> Bool
}

struct RemainStrategy: ListPrefetcherStrategy{
    var totalRowsCount: Int
    let remainRowsCount: Int
    
    func shouldFetch(_ scrollView: UIScrollView) -> Bool {
        let rowHeight = scrollView.contentSize.height / CGFloat(totalRowsCount)
        let needOffsetY = rowHeight * CGFloat(totalRowsCount - remainRowsCount)
        if scrollView.contentOffset.y + scrollView.frame.size.height > needOffsetY {
            return true
        } else {
            return false
        }
    }
    
    init(remainRowsCount:Int = 1) {
        self.remainRowsCount = remainRowsCount
        totalRowsCount = 0
    }
}


struct OffsetStrategy: ListPrefetcherStrategy {
    var totalRowsCount: Int
    let gap: Int
    let offset: Int
    
    func shouldFetch(_ scrollView: UIScrollView) -> Bool {
        let rowHeight = scrollView.contentSize.height / CGFloat(totalRowsCount)
        let actalOffset = totalRowsCount % gap
        let needOffsetY = actalOffset > offset ? scrollView.contentSize.height - CGFloat(actalOffset - offset) * rowHeight : scrollView.contentSize.height - CGFloat(2 * gap + offset) * rowHeight
        if scrollView.contentOffset.y + scrollView.frame.size.height > needOffsetY {
            return true
        } else {
            return false
        }
    }
    
    init(gap:Int, offset:Int) {
        self.gap = gap
        self.offset = offset
        totalRowsCount = 0
    }
}

struct ThresholdStrategy: ListPrefetcherStrategy{
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
    
    func shouldFetch(_ scrollView: UIScrollView) -> Bool {
        let viewRatio = (scrollView.contentOffset.y + scrollView.frame.size.height) / scrollView.contentSize.height
        let perPageCount = Double(totalRowsCount) / Double(currentPageIndex + 1)
        let needRowsCount = perPageCount * (Double(currentPageIndex) + threshold)
        let actalThreshold = needRowsCount / Double(totalRowsCount)
        
        if Double(viewRatio) >= actalThreshold {
            return true
        } else {
            return false
        }
    }
    
    public init(threshold:Double = 0.7) {
        self.threshold = threshold
        totalRowsCount = 0
    }
}




