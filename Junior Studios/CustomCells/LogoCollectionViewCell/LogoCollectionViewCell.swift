//
//  LogoCollectionViewCell.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/12/21.
//

import UIKit

class LogoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewWIdth: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var curvedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var photosNumberLabel: UILabel!
    @IBOutlet weak var videosNumberLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        imageViewHeight.constant = UIScreen.main.bounds.height / 2.5 - 80
        imageViewWIdth.constant = UIScreen.main.bounds.width
        
        let smallCornerRadius = UIScreen.main.bounds.width * 0.1
        let bigCornerRadius = UIScreen.main.bounds.width * 0.26

        
        curvedViewHeightConstraint.constant = 80
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = bigCornerRadius
        imageView.layer.maskedCorners = [.layerMaxXMaxYCorner]

        curvedView.clipsToBounds = true
        curvedView.layer.cornerRadius = smallCornerRadius
        curvedView.layer.maskedCorners = [.layerMinXMinYCorner]
    
        
    }

}
