//
//  AlbumAssetModel.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/11/21.
//

import UIKit
import Photos

struct AlbumAssetModel {
    
    var isFavorite: Bool
    var creationDate: String
    var mediaType: String
    var image: UIImage
    
    init(isFavorite: Bool, creationDate: Date, mediaType: PHAssetMediaType, image: UIImage) {
        
        self.image = image
        self.isFavorite = isFavorite
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, h:mm a"
        self.creationDate = dateFormatter.string(from: creationDate)
        
        switch mediaType {
        case .image: self.mediaType = "Image"
        case .audio: self.mediaType = "Audio"
        case .video: self.mediaType = "Video"
        case .unknown: self.mediaType = "Unknown"
        default: self.mediaType = "Unknown"
        }

        
        
    }
    
    
}
