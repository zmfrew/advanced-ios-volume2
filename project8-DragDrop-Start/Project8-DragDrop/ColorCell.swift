//
//  ColorCell.swift
//  Project8-DragDrop
//
//  Created by Paul Hudson on 24/06/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
    @IBOutlet var swatch: UIView!
    @IBOutlet var textLabel: UILabel!

    override func awakeFromNib() {
        swatch.layer.cornerRadius = 50
        swatch.layer.borderWidth = 1
    }
}

