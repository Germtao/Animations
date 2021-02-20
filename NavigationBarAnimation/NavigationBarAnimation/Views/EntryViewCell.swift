//
//  EntryViewCell.swift
//  NavigationBarAnimation
//
//  Created by QDSG on 2021/2/20.
//

import UIKit

class EntryViewCell: UITableViewCell {
    
    static let reuseIdentifier = "EntryViewCellID"
    static let className = "EntryViewCell"

    @IBOutlet private weak var entryLabel: UILabel!
    @IBOutlet private weak var entryImageView: UIImageView!
    
    func update(_ entry: Entry) {
        entryLabel.text = entry.title
        entryImageView.image = entry.image
    }
}
