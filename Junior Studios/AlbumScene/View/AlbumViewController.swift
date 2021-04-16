//
//  AlbumViewController.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/11/21.
//

import UIKit
import Photos
import RxSwift
import RxCocoa
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
    
    private let bag = DisposeBag()
    private lazy var viewModel: AlbumViewModel = {
        return AlbumViewModel(album: album!)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModelBinding()
        configureCollectionView()
        
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
    
    func viewModelBinding() {
        viewModel.albumAssetsBehavior
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }).disposed(by: bag)
        
        viewModel.fetchAssets()
    }
    
    func configureCollectionView() {
        collectionView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(sender:))))
        
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
        return viewModel.albumAssetsBehavior.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! AlbumsCollectionViewCell
        guard !viewModel.albumAssetsBehavior.value.isEmpty else { return cell }
        let asset = viewModel.albumAssetsBehavior.value[indexPath.row]
        cell.playImageView.alpha = asset.mediaType == .image ? 0 : 1
        cell.photoImageView.image = asset.image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = viewModel.albumAssetsBehavior.value[indexPath.row]
        if asset.mediaType == .image {
            let vc = UIStoryboard(name: "PhotoDetails", bundle: nil).instantiateInitialViewController() as! PhotoDetailsViewController
            vc.asset = asset
            vc.title = "Image"
            navigationController?.pushViewController(vc, animated: true)
        } else if asset.mediaType == .video {
            let vc = UIStoryboard(name: "VideoDetails", bundle: nil).instantiateInitialViewController() as! VideoDetailsViewController
            vc.url = asset.avURL?.url
            vc.title = "Video"
            navigationController?.pushViewController(vc, animated: true)
        }
//        let vc = UIStoryboard(name: "AlbumDetailed", bundle: nil).instantiateInitialViewController() as! AlbumDetailedViewController
//        vc.assetModels = viewModel.albumAssetsBehavior.value
//        vc.index = indexPath.row
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
