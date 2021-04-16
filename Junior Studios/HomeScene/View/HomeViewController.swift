//
//  HomeViewController.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/10/21.
//

import UIKit
import RxCocoa
import RxSwift
import Photos


class HomeViewController: UIViewController {


    @IBOutlet weak var collectionView: UICollectionView!
    
    
    private let cellIdentifier = "GalleryCollectionViewCell"
    private let logoCellIdentifier = "LogoCollectionViewCell"
    
    private let bag = DisposeBag()
    private var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
	
        configureCollectionView()
        viewModelBinding()
        requestPHAuthorization()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        self.navigationController?.setStatusBar(backgroundColor: UIColor(rgb: 0x09252B))
    }
    
    func requestPHAuthorization() {
        PHPhotoLibrary.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized:
                self.viewModel.fetchCameraRollCollection()
                self.viewModel.fetchUserCreatedCollections()
            default:
                self.showNoAccessAlert()
            }
        }
    }
    
    private func viewModelBinding() {
        viewModel.assetCollectionsBehavior
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            }).disposed(by: bag)
        
        viewModel.imagesNumberBehavior
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            }).disposed(by: bag)
        
        viewModel.videosNumberBehavior
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            }).disposed(by: bag)
        
    }

    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(UINib(nibName: logoCellIdentifier, bundle: nil), forCellWithReuseIdentifier: logoCellIdentifier )
    }
    
    private func showNoAccessAlert() {
        let alert = UIAlertController(title: "No Photo Access",
                                      message: "Please grant Junior-Studios Photo Access in Settings -> Privacy",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Access", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:])
            }
        }))
        
        present(alert, animated: true)
        
        
    }
    


}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : viewModel.assetCollectionsBehavior.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: logoCellIdentifier, for: indexPath) as! LogoCollectionViewCell
            cell.photosNumberLabel.text = viewModel.imagesNumberBehavior.value > 0 ? "\(viewModel.imagesNumberBehavior.value) Items" : "\(viewModel.imagesNumberBehavior.value) Item"
            cell.videosNumberLabel.text = viewModel.videosNumberBehavior.value > 0 ? "\(viewModel.videosNumberBehavior.value) Items" : "\(viewModel.videosNumberBehavior.value) Item"
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GalleryCollectionViewCell
            guard !viewModel.assetCollectionsBehavior.value.isEmpty else { return cell }
            let album = viewModel.assetCollectionsBehavior.value[indexPath.row]
            cell.folderImageView.image = album.thumbnailImage
            cell.folderNameLabel.text = album.name
            cell.itemsNoLabel.text = "\(album.count!) Items"
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard !viewModel.assetCollectionsBehavior.value.isEmpty, indexPath.section != 0 else { return }
        let album = viewModel.assetCollectionsBehavior.value[indexPath.row]

        let vc = UIStoryboard(name: "Album", bundle: nil).instantiateInitialViewController() as! AlbumViewController
        vc.album = album
        vc.title = album.name
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: view.frame.width, height: UIScreen.main.bounds.height / 2.5)
        } else {
            return CGSize(width: view.frame.width / 2 - 10, height: view.frame.width / 2 + 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return .zero
        } else {
            return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        }
    }
    
   
    
    
    
}

