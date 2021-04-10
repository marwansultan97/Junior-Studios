//
//  HomeViewController.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/10/21.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellIdentifier = "GalleryCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
	
        configureUI()
        configureCollectionView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isHidden = true
    }


    func configureUI() {
        let smallCornerRadius = view.frame.width * 0.18
        let bigCornerRadius = view.frame.width * 0.3
        
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
    
    
    
    
    

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GalleryCollectionViewCell
        return cell
    }
    
    
    
}
