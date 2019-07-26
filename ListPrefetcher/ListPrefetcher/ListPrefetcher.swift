//
//  ListPrefetcher.swift
//  WGXListPrefetcher
//
//  Created by Nemo on 2019/7/23.
//

import UIKit

/// 预加载代理
public protocol ListPrefetcherDelegate:AnyObject {
    
    /// 总行数
    var totalRowsCount:Int { get }
    
    /// 开始预加载时
    func startFetch()
}


/// 可自定义的预加载策略
public protocol ListPrefetcherStrategy {
    
    /// 总行数
    var totalRowsCount:Int { get set }
    
    /// 判断是否应该加载
    /// - Parameter totalHeight: 列表总高度
    /// - Parameter offsetY: 目前偏移量
    func shouldFetch(totalHeight:CGFloat, offsetY:CGFloat) -> Bool
}


public class ListPrefetcher:NSObject {
    public weak var delegate: ListPrefetcherDelegate?
    @objc let scrollView:UIScrollView
    var contentSizeObserver:NSKeyValueObservation?
    var contentOffsetObserver:NSKeyValueObservation?
    var strategy: ListPrefetcherStrategy
    
    
    /// 初始化方法
    /// - Parameter strategy: 使用的策略
    /// - Parameter scrollView: 监听的 scrollView
    public init(strategy:ListPrefetcherStrategy, scrollView:UIScrollView) {
        self.strategy = strategy
        self.scrollView = scrollView
        super.init()
    }
    
    /// 开始，一般在 viewWillAppear 调用
    public func start() {
        contentSizeObserver = observe(\.scrollView.contentSize) { object, _ in
            guard let delegate = object.delegate else { return }
            object.strategy.totalRowsCount = delegate.totalRowsCount
        }
        
        contentOffsetObserver = observe(\.scrollView.contentOffset) { object, _ in
            let offsetY = object.scrollView.contentOffset.y + object.scrollView.frame.height
            let totalHeight = object.scrollView.contentSize.height
            guard offsetY < totalHeight else { return }
            if object.strategy.shouldFetch(totalHeight: totalHeight, offsetY: offsetY) {
                object.delegate?.startFetch()
            }
        }
    }
    
    /// 停止监听，一般在 viewWillDisapper 调用
    public func stop() {
        contentSizeObserver?.invalidate()
        contentOffsetObserver?.invalidate()
    }
}

