//
//  HomeViewController.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/10/21.
//

import UIKit
import Photos

class HomeViewController: UIViewController {

    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var albumModels = [AlbumModel]()
    private let cellIdentifier = "GalleryCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
	
        configureUI()
        configureCollectionView()
        requestPHAuthorization()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isHidden = true
    }
    
    func requestPHAuthorization() {
        PHPhotoLibrary.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized: self.fetchCollections()
            default: self.showNoAccessAlert()
            }
        }
    }
    
    func fetchCollections() {
        
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
                
        smartAlbums.enumerateObjects { (collection, index, UnsafeMutablePointer) in



            let fetchOptions = PHFetchOptions()
            let descriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchOptions.sortDescriptors = [descriptor]
            
            let fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            guard let assest = fetchResult.firstObject else { return }
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .fastFormat
            requestOptions.resizeMode = .exact
            requestOptions.isSynchronous = true
            let size = CGSize(width: UIScreen.main.bounds.width / 2 - 10, height: UIScreen.main.bounds.width / 2 - 10)
            PHImageManager.default().requestImage(for: assest, targetSize: size, contentMode: .aspectFill, options: requestOptions) { (image, info) in
                guard let image = image else { return }
                let album = AlbumModel(name: collection.localizedTitle!, collection: collection, image: image)
                self.albumModels.append(album)
            }

        }
        
        userAlbums.enumerateObjects { (collection, index, UnsafeMutablePointer) in
            
            
            
            let fetchOptions = PHFetchOptions()
            let descriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchOptions.sortDescriptors = [descriptor]
            
            let fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            guard let assest = fetchResult.firstObject else { return }
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .fastFormat
            requestOptions.resizeMode = .exact
            requestOptions.isSynchronous = true
            let size = CGSize(width: UIScreen.main.bounds.width / 2 - 10, height: UIScreen.main.bounds.width / 2 - 10)
            PHImageManager.default().requestImage(for: assest, targetSize: size, contentMode: .aspectFill, options: requestOptions) { (image, info) in
                guard let image = image else { return }
                let album = AlbumModel(name: collection.localizedTitle!, collection: collection, image: image)
                self.albumModels.append(album)
            }
            
            
        }

        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }


    func configureUI() {
        let smallCornerRadius = view.frame.width * 0.18
        let bigCornerRadius = view.frame.width * 0.268
        
        logoHeightConstraint.constant = view.frame.height / 3.5
        logoImage.clipsToBounds = true
        logoImage.layer.cornerRadius = bigCornerRadius
        logoImage.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = smallCornerRadius
        contentView.layer.maskedCorners = [.layerMinXMinYCorner]
    }
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width / 2 - 10, height: view.frame.width / 2 + 40)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .vertical
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }
    
    private func showNoAccessAlert() {
        let alert = UIAlertController(title: "No Photo Access",
                                      message: "Please grant Junior-Studios Photo Access in Settings -> Privacy",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Access", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:])
            }
        }))
        
        present(alert, animated: true)
        
        
    }
    
    
    
    
    

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GalleryCollectionViewCell
        guard !albumModels.isEmpty else { return UICollectionViewCell() }
        let album = albumModels[indexPath.row]
        cell.folderImageView.image = album.thumbnailImage
        cell.folderNameLabel.text = album.name
        cell.itemsNoLabel.text = "\(album.count!)"
        return cell
    }
    
    
    
}
