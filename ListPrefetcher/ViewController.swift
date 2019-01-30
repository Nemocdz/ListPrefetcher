//
//  ViewController.swift
//  ListPrefetcher
//
//  Created by Nemo on 2019/1/30.
//  Copyright © 2019 nemocdz. All rights reserved.
//

import UIKit

private let reuseKey = "a"
class ViewController: UIViewController {
    var data = [0, 1, 2, 3, 4, 5, 6]
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseKey)
        tableView.rowHeight = 200
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(refresh(control:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        let listPrefetcher = ListPrefetcher(scrollView: tableView, dataOwner: self) { [weak self] in
            guard let self = self else { return }
            var last = self.data.last!
            for _ in 0..<6 {
                last += 1
                self.data.append(last)
            }
            self.tableView.reloadData()
        }
        
        listPrefetcher.start()
    }
    
    @objc func refresh(control:UIRefreshControl){
        data = [0, 1, 2, 3, 4, 5, 6]
        tableView.reloadData()
        control.endRefreshing()
    }
}

extension ViewController: ListPrefetcherDataOwner {
    func itemCount() -> Int {
        return data.count
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

