//
//  ViewController.swift
//  PullToRefreshAnimation
//
//  Created by QDSG on 2021/2/22.
//

import UIKit

class ViewController: UITableViewController, PullToRefreshViewDelegate {
    
    private var pullToRefreshView: PullToRefreshView!
    
    private let kPullRefreshViewHeight = UIScreen.main.bounds.height * 0.22
    
    private let items = [
        "Avatar",
        "Star Wars",
        "Interstellar",
        "Predator",
        "The Martian",
        "They Live",
        "Contact",
        "Alien",
        "Independence Day",
        "Signs",
        "District 9",
        "Superman Returns"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureTableView()
        
        configureRefreshRect()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pullToRefreshView.scrollViewDidScroll(scrollView)
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        pullToRefreshView.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    // MARK: - PullToRefreshViewDelegate
    func pullToRefreshViewDidRefresh(_ pullToRefreshView: PullToRefreshView) {
        delay(seconds: 2.5) {
            pullToRefreshView.endRefreshing()
        }
    }
    
    private func configureRefreshRect() {
        let refreshRect = CGRect(x: 0.0, y: -kPullRefreshViewHeight, width: view.frame.width, height: kPullRefreshViewHeight)
        pullToRefreshView = PullToRefreshView(frame: refreshRect, scrollView: tableView)
        pullToRefreshView.delegate = self
        view.addSubview(pullToRefreshView)
    }
    
    private func configureTableView() {
        tableView.backgroundColor = Constants.ColorPalette.backgroundColor
    }

    private func configureNavBar() {
        navigationController?.navigationBar.barTintColor = Constants.ColorPalette.pruple
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}

