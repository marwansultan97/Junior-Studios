//
//  CustomPlayerView.swift
//  Junior Studios
//
//  Created by Marwan Osama on 4/15/21.
//

import UIKit
import AVFoundation
import AVKit

class CustomPlayerView: UIView {

    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            return playerLayer.player = newValue
        }
    }


}
