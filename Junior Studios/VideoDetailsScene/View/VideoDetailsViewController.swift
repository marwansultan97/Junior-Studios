//
//  VideoDetailsViewController.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/16/21.
//

import UIKit
import RxSwift
import RxCocoa
import Player
import CoreMedia

class VideoDetailsViewController: UIViewController {
    
    @IBOutlet weak var progressViewHeight: NSLayoutConstraint!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var playPauseImage: UIImageView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var playerViewContainer: UIView!
    @IBOutlet weak var videoSlider: UISlider!
    @IBOutlet weak var timeProgressLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    private let bag = DisposeBag()
    private var player = Player()
    private var isPlayingBehavior = BehaviorRelay<Bool>(value: false)
    var url: URL?
    var isExpanded = true
    
    var duration: Double = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupVideoPlayer()
        setupSlider()
        configureUI()
        setupVideoButtons()
        
        playerViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:))))

    }
    
    override func viewDidLayoutSubviews() {
        player.view.frame = playerViewContainer.bounds
        playerViewContainer.addSubview(player.view)
        playerViewContainer.bringSubviewToFront(progressView)
        playerViewContainer.bringSubviewToFront(playPauseImage)
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        if isExpanded {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            UIView.animate(withDuration: 0.2) {
                self.progressViewHeight.constant = 0
                self.view.layoutIfNeeded()
            }
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            UIView.animate(withDuration: 0.2) {
                self.progressViewHeight.constant = 100
                self.view.layoutIfNeeded()
            }
        }
        isExpanded.toggle()
    }
    
    private func configureUI() {
        progressView.layer.cornerRadius = 20
        progressView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    

    private func setupVideoPlayer() {
        player.playerDelegate = self
        player.playbackDelegate = self
        player.fillMode = .resizeAspectFill
        player.url = url ?? URL(string: "google.com")
        
        isPlayingBehavior.subscribe(onNext: { [weak self] isPlaying in
            guard let self = self else { return }
            self.showPlayPauseImage()
            if isPlaying {
                self.player.playerLayer()?.player?.play()
                self.playPauseButton.setImage(UIImage(named: "SF_pause"), for: .normal)
            } else {
                self.player.pause()
                self.playPauseButton.setImage(UIImage(named: "SF_play"), for: .normal)
            }
        }).disposed(by: bag)
    }
    
    private func setupVideoButtons() {
        playPauseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.isPlayingBehavior.value {
                    self.isPlayingBehavior.accept(false)
                } else {
                    self.isPlayingBehavior.accept(true)
                }
            }).disposed(by: bag)
        
        forwardButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isPlayingBehavior.accept(false)
                let totalTime = self.player.maximumDuration
                let seconds = (Double(self.videoSlider.value) * totalTime) + 5
                let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                self.player.seek(to: time)
                self.isPlayingBehavior.accept(true)

            }).disposed(by: bag)
        
        backwardButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isPlayingBehavior.accept(false)
                let totalTime = self.player.maximumDuration
                let seconds = (Double(self.videoSlider.value) * totalTime) - 5
                let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                self.player.seek(to: time)
                self.isPlayingBehavior.accept(true)

            }).disposed(by: bag)
        
        
    }
    
    private func setupSlider() {
        videoSlider.rx.value.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            guard self.videoSlider.isTracking == true else { return }
            self.isPlayingBehavior.accept(false)
            let totalTime = self.player.maximumDuration
            let seconds = Double(value) * totalTime
            let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            self.player.seek(to: time)
            self.isPlayingBehavior.accept(true)
            
            let duration = self.secondsToHoursMinutesSeconds(seconds: Int(seconds))
            let hours = duration.0
            let minutes = duration.1
            let second = duration.2
            
            self.timeProgressLabel.text = hours == 0 ? String(format: "%0.2d:%0.2d", minutes,second) : String(format: "%0.2d:%0.2d:%0.2d", hours,minutes,second)

            
        }).disposed(by: bag)
    }

    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func showPlayPauseImage() {
        guard videoSlider.isTracking == false else { return }
        if isPlayingBehavior.value {
            playPauseImage.image = UIImage(named: "SF_play_circle_fill")
            UIView.animate(withDuration: 0.3) {
                self.playPauseImage.alpha = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.3) {
                    self.playPauseImage.alpha = 0
                }
            }
        } else {
            playPauseImage.image = UIImage(named: "SF_pause_circle_fill")
            UIView.animate(withDuration: 0.3) {
                self.playPauseImage.alpha = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.3) {
                    self.playPauseImage.alpha = 0
                }
            }
        }
    }
}

extension VideoDetailsViewController: PlayerDelegate, PlayerPlaybackDelegate {
    
    func playerReady(_ player: Player) {
        
        let duration = secondsToHoursMinutesSeconds(seconds: Int(player.maximumDuration))
        let hours = duration.0
        let minutes = duration.1
        let seconds = duration.2
        
        durationLabel.text = hours == 0 ? String(format: "%0.2d:%0.2d", minutes,seconds) : String(format: "%0.2d:%0.2d:%0.2d", hours,minutes,seconds)
        
        self.duration = player.maximumDuration
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        if let err = error {
            print(err)
            return
        }
    }
    
    func playerCurrentTimeDidChange(_ player: Player) {
        let duration = secondsToHoursMinutesSeconds(seconds: Int(player.currentTime.seconds))
        let hours = duration.0
        let minutes = duration.1
        let seconds = duration.2
        
        timeProgressLabel.text = hours == 0 ? String(format: "%0.2d:%0.2d", minutes,seconds) : String(format: "%0.2d:%0.2d:%0.2d", hours,minutes,seconds)
        
        guard videoSlider.isTracking == false else { return }
        videoSlider.value = Float(player.currentTime.seconds / self.duration)
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
        
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        self.isPlayingBehavior.accept(false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIView.animate(withDuration: 0.2) {
            self.progressViewHeight.constant = 100
            self.view.layoutIfNeeded()
        }
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
        
    }
    
    func playerPlaybackDidLoop(_ player: Player) {
        
    }
    
    
}
