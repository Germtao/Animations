//
//  ViewController.swift
//  NavigationBarAnimation
//
//  Created by QDSG on 2021/2/20.
//

import UIKit

class ViewController: UITableViewController {
    
    private var barHidden = false
    
    private var entries = [
        Entry(title: "First Entry", image: #imageLiteral(resourceName: "one")),
        Entry(title: "Second Entry", image: #imageLiteral(resourceName: "two")),
        Entry(title: "Third Entry", image: #imageLiteral(resourceName: "three")),
        Entry(title: "Fourth Entry", image: #imageLiteral(resourceName: "four")),
        Entry(title: "Fifth Entry", image: #imageLiteral(resourceName: "five")),
        Entry(title: "Sixth Entry", image: #imageLiteral(resourceName: "six"))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return barHidden ? .lightContent : .default
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EntryViewCell.reuseIdentifier,
                                                 for: indexPath) as! EntryViewCell
        cell.update(entries[indexPath.row])
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if navigationController?.navigationBar.isHidden == true {
            barHidden = true
        } else {
            barHidden = false
        }
        setNeedsStatusBarAppearanceUpdate()
    }
}

