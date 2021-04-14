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
    let creationDate: Date
    let mediaType: PHAssetMediaType
    var image: UIImage?
    var avURL: AVURLAsset?
   
}
