//
//  PhotoDetailsViewController.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/16/21.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    
    var asset: AlbumAssetModel?
    
    var isZooming = false
    var originalCenter: CGPoint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPhotoImage()
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.alpha = 1
        navigationController?.navigationBar.isHidden = false
    }

    func setupPhotoImage() {
        photoImageView.image = asset?.image
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(sender:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction(sender:)))
        pinchGesture.delegate = self
        panGesture.delegate = self
        photoImageView.addGestureRecognizer(pinchGesture)
        photoImageView.addGestureRecognizer(panGesture)
    }

    @objc func panAction(sender: UIPanGestureRecognizer) {
        guard let view = sender.view else { return }
        if sender.state == .changed && isZooming {
            let translation = sender.translation(in: view)
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            sender.setTranslation(.zero, in: view)
        }
    }
    
    @objc func pinchAction(sender: UIPinchGestureRecognizer) {
        guard let view = sender.view else { return }
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = .black
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.setStatusBar(backgroundColor: UIColor(rgb: 0x000000))
        }
        
        if sender.numberOfTouches == 1 {
            UIView.animate(withDuration: 0.3) {
                self.photoImageView.transform = .identity
            }
        }
        switch sender.state {
        case .began:
            originalCenter = photoImageView.center
            isZooming = true
        case .changed:
            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                      y: sender.location(in: view).y - view.bounds.midY)
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            view.transform = transform
            sender.scale = 1
        case .ended:
            guard let center = originalCenter else { return }
            UIView.animate(withDuration: 0.3) {
                self.photoImageView.transform = .identity
                self.photoImageView.center = center
                self.view.backgroundColor = .white
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.navigationController?.setStatusBar(backgroundColor: UIColor(rgb: 0x09252B))
            }
            isZooming = false
        default:
            break
        }
        
    }
    
}

extension PhotoDetailsViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

