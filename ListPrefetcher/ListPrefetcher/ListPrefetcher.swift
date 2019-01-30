//
//  ListPrefetcher.swift
//  ListPrefetcher
//
//  Created by Nemo on 2019/1/30.
//  Copyright © 2019 nemocdz. All rights reserved.
//

import UIKit

class ListPrefetcher:NSObject{
    let threshold: CGFloat
    let column :Int
    let fetchHandler:()->()
    @objc let scrollView:UIScrollView
    
    var currentPage: Int = 0
    var contentSizeObserver:NSKeyValueObservation?
    var contentOffsetObserver:NSKeyValueObservation?
    weak var dataOwner:ListPrefetcherDataOwner?
    
    public func start() {
        contentSizeObserver = observe(\.scrollView.contentSize, options: [.new, .old]) { (_, change) in
            guard let newSize = change.newValue, let oldSize = change.oldValue else { return }
            
            if newSize.height < oldSize.height {
                self.currentPage = 0
            }
        }
        
        contentOffsetObserver = observe(\.scrollView.contentOffset){ (_, _) in
            guard let dataOwner = self.dataOwner else { return }
            let currentOffsetY = self.scrollView.contentOffset.y + self.scrollView.frame.size.height
            let viewRatio = currentOffsetY / self.scrollView.contentSize.height
            
            let totalCount = Int(ceil(CGFloat(dataOwner.itemCount()) / CGFloat(self.column)))
            let pageCount = CGFloat(totalCount) / CGFloat(self.currentPage + 1)
            
            let needReadCount = pageCount * (CGFloat(self.currentPage) + self.threshold)
            let dataThreshold = needReadCount / CGFloat(totalCount)
            
            if viewRatio >= dataThreshold {
                self.currentPage += 1
                self.fetchHandler()
            }
        }
    }
    
    public func stop() {
        contentSizeObserver?.invalidate()
        contentOffsetObserver?.invalidate()
    }
    
    public init(threshold:CGFloat = 0.6, column:Int = 1, scrollView:UIScrollView, dataOwner:ListPrefetcherDataOwner, fetchHandler:@escaping ()->()) {
        self.threshold = threshold
        self.fetchHandler = fetchHandler
        self.column = column
        self.scrollView = scrollView
        self.dataOwner = dataOwner
    }
}

public protocol ListPrefetcherDataOwner:AnyObject {
    func itemCount() -> Int
}
