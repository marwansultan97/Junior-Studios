//
//  AlbumViewModel.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/15/21.
//

import Foundation
import RxSwift
import RxCocoa
import Photos


class AlbumViewModel {
    
    
    
    var albumAssetsBehavior = BehaviorRelay<[AlbumAssetModel]>(value: [])
    
    
    var album: AlbumModel
    
    init(album: AlbumModel) {
        self.album = album
    }
    
    
    func fetchAssets() {
      
        let fetchOptions = PHFetchOptions()
        let descriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [descriptor]
        
        let fetchResult = PHAsset.fetchAssets(in: album.collection, options: fetchOptions)
        
        
        fetchResult.enumerateObjects { (phAsset, index, UnsafeMutablePointer) in
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.resizeMode = .exact
            requestOptions.isSynchronous = false
            requestOptions.version = .original
            let maxDimension = UIScreen.main.bounds.height * UIScreen.main.scale
            let size = CGSize(width: maxDimension, height: maxDimension)
            
            
            if phAsset.mediaType == .image {
                PHImageManager.default().requestImage(for: phAsset, targetSize: size, contentMode: .default, options: requestOptions) { (image, info) in
                    guard let image = image else { return }
                    let asset = AlbumAssetModel(isFavorite: phAsset.isFavorite,
                                                creationDate: phAsset.creationDate ?? Date(),
                                                mediaType: phAsset.mediaType,
                                                image: image,
                                                avURL: nil)
                    self.albumAssetsBehavior.accept(self.albumAssetsBehavior.value + [asset])
                }
            } else if phAsset.mediaType == .video {
                PHImageManager.default().requestImage(for: phAsset, targetSize: size, contentMode: .default, options: requestOptions) { (image, info) in
                    guard let image = image else { return }
                    
                    let videoOptions = PHVideoRequestOptions()
                    videoOptions.deliveryMode = .highQualityFormat
                    videoOptions.isNetworkAccessAllowed = false
                    
                    
                    PHImageManager.default().requestAVAsset(forVideo: phAsset, options: videoOptions) { (avAsset, avAudioMix, info) in
                        if let assetURL = avAsset as? AVURLAsset {
                            let asset = AlbumAssetModel(isFavorite: phAsset.isFavorite,
                                                        creationDate: phAsset.creationDate ?? Date(),
                                                        mediaType: phAsset.mediaType,
                                                        image: image,
                                                        avURL: assetURL)
                            self.albumAssetsBehavior.accept(self.albumAssetsBehavior.value + [asset])
                        }
                    }
                    
                }
            }
        }
        
        
    }
    
    
    
}
