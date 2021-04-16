//
//  AlbumDetailedViewController.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/12/21.
//

import UIKit
import Photos
import AVFoundation
import AVKit
import AnimatedCollectionViewLayout
import RxSwift
import RxCocoa

class AlbumDetailedViewController: UIViewController {

    @IBOutlet weak var sCollectionView: UICollectionView!
    @IBOutlet weak var bCollectionView: UICollectionView!
    
    private let cellIdentifier = "AlbumCollectionViewCell"
    private let bag = DisposeBag()
    
    var assetModels = [AlbumAssetModel]()
    
    var index: Int?
    
    
    var centerIndex: Int = 0
    
    var isZooming = false
    var originalCenter: CGPoint?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionViews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        bCollectionView.scrollToItem(at: IndexPath(item: index!, section: 0), at: .right, animated: false)
//        sCollectionView.scrollToItem(at: IndexPath(item: index!, section: 0), at: .right, animated: false)
        bCollectionView.reloadData()
    }

    
    
    func configureCollectionViews() {
        sCollectionView.delegate = self
        sCollectionView.dataSource = self
        let sLayout = UICollectionViewFlowLayout()
        sLayout.itemSize = CGSize(width: sCollectionView.frame.width / 10, height: sCollectionView.frame.height)
        sLayout.minimumInteritemSpacing = 0
        sLayout.minimumLineSpacing = 5
        sLayout.sectionInset = UIEdgeInsets(top: 3, left: 5, bottom: 0, right: 5)
        sLayout.scrollDirection = .horizontal
        sCollectionView.collectionViewLayout = sLayout
        sCollectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
        bCollectionView.delegate = self
        bCollectionView.dataSource = self
        bCollectionView.isPagingEnabled = true
        let bLayout = AnimatedCollectionViewLayout()
        bLayout.animator = ZoomInOutAttributesAnimator()
        bLayout.scrollDirection = .horizontal
        bCollectionView.collectionViewLayout = bLayout
        bCollectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }

}

//MARK: - CollectionView Delegate, DataSource
extension AlbumDetailedViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == sCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! AlbumCollectionViewCell
            guard !assetModels.isEmpty else { return cell }
            let asset = assetModels[indexPath.row]
            cell.playerView.alpha = 0
            cell.photoImageView.image = asset.image
            cell.playImageView.alpha = asset.mediaType == .image ? 0 : 1
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! AlbumCollectionViewCell
            guard !assetModels.isEmpty else { return cell }
            let asset = assetModels[indexPath.row]
            if asset.mediaType == .image {
                cell.setupImageCell(image: asset.image!)
            } else {
                cell.setupVideoCell(url: asset.avURL!.url)
            }
            cell.playImageView.alpha = 0
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == sCollectionView {
            bCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        }
    }
 
    
}

//MARK: - CollectionView Delegate
extension AlbumDetailedViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == bCollectionView {
            let convertedPoint = view.convert(CGPoint(x: view.frame.width / 2, y: 300), to: bCollectionView)
            centerIndex = bCollectionView.indexPathForItem(at: convertedPoint)?.item ?? centerIndex
            self.sCollectionView.reloadData()
            if centerIndex < assetModels.count - 8 {
                let point = CGPoint(x: CGFloat(centerIndex) * sCollectionView.frame.width / 10 , y: 0)
                sCollectionView.setContentOffset(point, animated: true)
            }
        }
    }
    
    
}

//MARK: - CollectionView DelegateFlowLayout
extension AlbumDetailedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == bCollectionView {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == sCollectionView ? 5 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == sCollectionView {

            if indexPath.item == centerIndex {
                return CGSize(width: sCollectionView.frame.width / 5, height: sCollectionView.frame.height - 15)
            } else {
                return CGSize(width: sCollectionView.frame.width / 10, height: sCollectionView.frame.height / 2)
            }
        } else {
            return CGSize(width: bCollectionView.frame.width, height: bCollectionView.frame.height - 15)
        }
        
    }
}

