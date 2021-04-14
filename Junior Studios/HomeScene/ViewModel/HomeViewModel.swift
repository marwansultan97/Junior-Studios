//
//  HomeViewModel.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/14/21.
//

import Foundation
import RxCocoa
import RxSwift
import Photos


class HomeViewModel {
    
    
    var assetCollectionsBehavior = BehaviorRelay<[AlbumModel]>(value: [])
    var imagesNumberBehavior = BehaviorRelay<Int>(value: 0)
    var videosNumberBehavior = BehaviorRelay<Int>(value: 0)
    
    
    
    
    
    func fetchUserCreatedCollections() {
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        
        
        userAlbums.enumerateObjects { (collection, index, UnsafeMutablePointer) in
            
            let fetchOptions = PHFetchOptions()
            let descriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchOptions.sortDescriptors = [descriptor]
            
            let fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            guard let assest = fetchResult.firstObject else { return }
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.resizeMode = .exact
            requestOptions.isSynchronous = false
            requestOptions.version = .original
            requestOptions.isNetworkAccessAllowed = true
            let maxDimension = UIScreen.main.bounds.width * UIScreen.main.scale
            let size = CGSize(width: maxDimension, height: maxDimension)
            PHImageManager.default().requestImage(for: assest, targetSize: size, contentMode: .aspectFill, options: requestOptions) { (image, info) in
                guard let image = image else { return }
                let album = AlbumModel(name: collection.localizedTitle!, collection: collection, image: image)
                self.assetCollectionsBehavior.accept(self.assetCollectionsBehavior.value + [album])
            }
            
        }
    }
    
    
    func fetchCameraRollCollection() {
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
                
        smartAlbums.enumerateObjects { (collection, index, UnsafeMutablePointer) in

            let fetchOptions = PHFetchOptions()
            let descriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchOptions.sortDescriptors = [descriptor]

            let fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            
            fetchResult.enumerateObjects { (asset, index, info) in
                if index == 0 {
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.deliveryMode = .highQualityFormat
                    requestOptions.resizeMode = .exact
                    requestOptions.isSynchronous = false
                    requestOptions.version = .original
                    let maxDimension = UIScreen.main.bounds.width * UIScreen.main.scale
                    let size = CGSize(width: maxDimension, height: maxDimension)
                    PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { (image, info) in
                        guard let image = image else { return }
                        let album = AlbumModel(name: collection.localizedTitle!, collection: collection, image: image)
                        self.assetCollectionsBehavior.accept(self.assetCollectionsBehavior.value + [album])
                    }
                }
                
                if asset.mediaType == .image {
                    self.imagesNumberBehavior.accept(self.imagesNumberBehavior.value + 1)
                } else if asset.mediaType == .video {
                    self.videosNumberBehavior.accept(self.videosNumberBehavior.value + 1)
                }
            }
        }
    }
    
    
    
    
    
}
