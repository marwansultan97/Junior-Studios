//
//  GalleryCollectionViewCell.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/11/21.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var folderImageView: UIImageView!
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var itemsNoLabel: UILabel!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 15
        folderImageView.layer.cornerRadius = 15
        imageWidth.constant = UIScreen.main.bounds.width / 2 - 10
        imageHeight.constant = UIScreen.main.bounds.width / 2 - 10
    }

}
