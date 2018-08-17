//
//  LivePlayerController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/17.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import AVKit

class LivePlayerController: AVPlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://live.nfls.io/test.m3u8")!
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
    }
}
