//
//  AlbumsCollectionViewCell.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/14/21.
//

import UIKit

class AlbumsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        photoImageView.layer.cornerRadius = 10
    }

}
