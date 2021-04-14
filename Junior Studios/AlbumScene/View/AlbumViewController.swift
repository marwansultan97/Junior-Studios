//
//  AlbumViewController.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/11/21.
//

import UIKit
import Photos
import AnimatedCollectionViewLayout

class AlbumViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellIdentifier = "AlbumsCollectionViewCell"
    
    var layout = UICollectionViewFlowLayout()
    var scale: CGFloat = 0.0
    var zoomNumber = 1
    var width: CGFloat = UIScreen.main.bounds.width / 2 - 7.5
    var minimumInteritemSpacing: CGFloat = 0
    var minimumLineSpacing: CGFloat = 5
    
    var album: AlbumModel?
    var albumAssets = [AlbumAssetModel]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        fetchImages()
        
        collectionView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(sender:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc func pinchAction(sender: UIPinchGestureRecognizer) {
        scale = sender.scale
        switch sender.state {
        case .ended:
            if scale > 2 {
                guard zoomNumber < 2 else { return }
                zoomNumber += 1
                width = width * 3 / 2
                minimumLineSpacing = minimumLineSpacing * 3 / 2
                UIView.animate(withDuration: 0.3) {
                    self.layout.itemSize = CGSize(width: self.width, height: self.width )
                    self.layout.minimumLineSpacing = self.minimumLineSpacing
                    self.view.layoutIfNeeded()
                }


            } else if scale < 0.5 {
                guard zoomNumber > 0 else { return }
                zoomNumber -= 1
                width = width * 2 / 3
                minimumLineSpacing = minimumLineSpacing * 2 / 3
                UIView.animate(withDuration: 0.3) {
                    self.layout.itemSize = CGSize(width: self.width, height: self.width)
                    self.layout.minimumLineSpacing = self.minimumLineSpacing
                    self.view.layoutIfNeeded()
                }
            } else {
                break
            }

        default:
            break
        }


    }
    
    
    func fetchImages() {
        guard let assetCollection = album?.collection else { return }
        let fetchOptions = PHFetchOptions()
        let descriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [descriptor]
        
        let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
        
        
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
                    self.albumAssets.append(asset)
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
                            self.albumAssets.append(asset)
                        }
                    }
                    
                }
            }
        }
        
    }

    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.scrollDirection = .vertical
        
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }
    

}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! AlbumsCollectionViewCell
        guard !albumAssets.isEmpty else { return cell }
        let asset = albumAssets[indexPath.row]
        cell.playImageView.alpha = asset.mediaType == .image ? 0 : 1
        cell.photoImageView.image = asset.image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "AlbumDetailed", bundle: nil).instantiateInitialViewController() as! AlbumDetailedViewController
        vc.assetModels = albumAssets
        vc.index = indexPath.row
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
