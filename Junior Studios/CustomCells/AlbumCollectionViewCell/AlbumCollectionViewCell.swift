//
//  AlbumCollectionViewCell.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/11/21.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    
    var isZooming = false
    var originalCenter: CGPoint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        
    }
    
    func setupView() {
        layer.cornerRadius = 5
        photoImageView.layer.cornerRadius = 5
        
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
            }
            isZooming = false
        default:
            break
        }
        
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
