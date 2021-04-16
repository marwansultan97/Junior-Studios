//
//  AlbumCollectionViewCell.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/11/21.
//

import UIKit
import RxCocoa
import RxSwift
import Player
import CoreMedia


class AlbumCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {

    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var timeProgressLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    
    let bag = DisposeBag()
    
    var isZooming = false
    var originalCenter: CGPoint?
    
    var duration = "0"
    var isPlaying = false
    var translation: CGFloat = 0
    var player = Player()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupVideoCell(url: URL) {
        playerView.alpha = 1
        photoImageView.alpha = 0
        player.playerDelegate = self
        player.playbackDelegate = self
        player.view.frame = playerView.bounds
        playerView.addSubview(player.view)
        playerView.bringSubviewToFront(progressView)
        player.url = url
        player.playerLayer()?.player?.play()
        
    }
    
    
    func setupImageCell(image: UIImage) {
        layer.cornerRadius = 5
        photoImageView.layer.cornerRadius = 5
        playerView.alpha = 0
        photoImageView.alpha = 1
        photoImageView.image = image
        
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

extension AlbumCollectionViewCell: PlayerPlaybackDelegate, PlayerDelegate {
    
    func playerReady(_ player: Player) {
        duration = String(format: "%0.f", player.maximumDuration)
        timeProgressLabel.text = "0 : " + duration
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        if player.playbackState == .playing {
            print("playing")
        } else if player.playbackState == .paused {
            print("paused")
        }
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        
    }
    
    
    func playerCurrentTimeDidChange(_ player: Player) {
        timeProgressLabel.text = String(format: "%0.f", player.currentTime.seconds) + " : " + duration
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
    
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
        
    }
    
    func playerPlaybackDidLoop(_ player: Player) {
        
    }
    
    
}
