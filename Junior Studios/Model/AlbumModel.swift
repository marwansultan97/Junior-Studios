//
//  AlbumModel.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/11/21.
//

import UIKit
import Photos

struct AlbumModel {
    var name: String
    var count: Int?
    var collection: PHAssetCollection
    var thumbnailImage: UIImage
    
    
    init(name: String, collection: PHAssetCollection, image: UIImage) {
        self.name = name
        self.collection = collection
        self.thumbnailImage = image
        
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        self.count = assets.count
        
        
        
    }
    
    
    
}
