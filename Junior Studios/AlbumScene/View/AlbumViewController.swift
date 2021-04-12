//
//  AlbumViewController.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/11/21.
//

import UIKit
import Photos

class AlbumViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var layout = UICollectionViewFlowLayout()
    private let cellIdentifier = "AlbumCollectionViewCell"
    var scale: CGFloat = 0.0
    var zoomNumber = 1
    
    var album: AlbumModel?
    
    var albumAssets = [AlbumAssetModel]()
    var width: CGFloat = UIScreen.main.bounds.width / 2 - 7.5
    var minimumInteritemSpacing: CGFloat = 0
    var minimumLineSpacing: CGFloat = 5
    
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
        
        
        fetchResult.enumerateObjects { (asset, index, UnsafeMutablePointer) in
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.resizeMode = .exact
            requestOptions.isSynchronous = true
            let size = CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
            PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { (image, info) in
                guard let image = image else { return }
                let asset = AlbumAssetModel(isFavorite: asset.isFavorite,
                                            creationDate: asset.creationDate ?? Date(),
                                            mediaType: asset.mediaType,
                                            image: image)
                
                self.albumAssets.append(asset)
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! AlbumCollectionViewCell
        guard !albumAssets.isEmpty else { return cell }
        let asset = albumAssets[indexPath.row]
        cell.photoImageView.image = asset.image
        return cell
    }
    
    
}
