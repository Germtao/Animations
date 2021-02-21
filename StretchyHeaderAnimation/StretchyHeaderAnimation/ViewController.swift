//
//  ViewController.swift
//  StretchyHeaderAnimation
//
//  Created by TT on 2021/2/21.
//

import UIKit

class ViewController: UITableViewController {
    
    private let tableHeaderHeight: CGFloat = 300.0
    
    var headerView: UIView!
    
    private let places = [
        Place(name: "Neuschwanstein Castle"),
        Place(name: "Yosemite National Park"),
        Place(name: "Times Square"),
        Place(name: "Tokyo"),
        Place(name: "Hawaii"),
        Place(name: "Eiffel Tower"),
        Place(name: "Rio de Janeiro"),
        Place(name: "Turkey"),
        Place(name: "Golden Gate Bridge"),
        Place(name: "Caribbean Islands")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        
        tableView.addSubview(headerView)
        
        tableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -tableHeaderHeight)
        
        updateHeaderView()
    }
    
    override var prefersStatusBarHidden: Bool { return true }
}

extension ViewController {
    private func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -tableHeaderHeight, width: tableView.bounds.width, height: tableHeaderHeight)
        if tableView.contentOffset.y < -tableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        headerView.frame = headerRect
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = places[indexPath.row].name
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
}

