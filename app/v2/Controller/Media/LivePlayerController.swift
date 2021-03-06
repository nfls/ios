//
//  LivePlayerController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/17.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import AVKit
import SCLAlertView

class LivePlayerController: AVPlayerViewController {
    var id: String? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://live.nfls.io/" + id! + ".m3u8")
        if let url = url {
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            player?.play()
        }
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .videoChat)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
