//
//  ViewController.swift
//  ListPrefetcher
//
//  Created by Nemo on 2019/1/30.
//  Copyright © 2019 nemocdz. All rights reserved.
//

import UIKit

private let reuseKey = "a"

enum RefreshState{
    case header
    case footer
}

class ViewController: UIViewController {
    var data = [Int]()
    var isLoading = false
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseKey)
        tableView.rowHeight = 200
        tableView.estimatedRowHeight = 1000
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(refresh(control:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    lazy var listPrefetcher: ListPrefetcher = {
        let listPrefetcher = ListPrefetcher(strategy: ThresholdStrategy(), scrollView: tableView)
        listPrefetcher.delegate = self
        return listPrefetcher
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        fetchData(.header)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listPrefetcher.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listPrefetcher.stop()
    }
    
    @objc func refresh(control:UIRefreshControl){
        fetchData(.header)
    }
    
    func fetchData(_ state:RefreshState){
        guard !isLoading else { return }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            switch state {
            case .header:
                self.data = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                self.tableView.refreshControl?.endRefreshing()
            case .footer:
                var last = self.data.last!
                for _ in 0..<6 {
                    last += 1
                    self.data.append(last)
                }
            }
            self.tableView.reloadData()
            self.isLoading = false
        }
    }
}

extension ViewController: ListPrefetcherDelegate {
    var totalRowsCount: Int {
        return data.count
    }
    
    func startFetch() {
        fetchData(.footer)
    }
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseKey, for: indexPath)
        cell.textLabel?.text = "\(data[indexPath.row])"
        return cell
    }
}

