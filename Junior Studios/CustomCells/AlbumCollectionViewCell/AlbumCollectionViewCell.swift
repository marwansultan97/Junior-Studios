//
//  AlbumCollectionViewCell.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/11/21.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        photoImageView.layer.cornerRadius = 5
    }

}
