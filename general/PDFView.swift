//
//  PDFView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/6/26.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import AVKit
import AVFoundation



class PDFViewController:UIViewController, WKNavigationDelegate{
    @IBOutlet weak var stackview: UIStackView!
    var path:String = ""
    var filename:String = ""
    var display = false
    
    override func viewDidAppear(_ animated: Bool) {
        if(!display){
            path = path.removingPercentEncoding!
            var ext = String(path.characters.reversed())
            let range = ext.range(of: ".")
            let index = ext.distance(from: ext.startIndex, to: range!.lowerBound)
            ext = (ext as NSString).substring(to: index)
            ext = String(ext.characters.reversed())
            switch(ext){
            case "mp3",
                 "mp4",
                 "m4a",
                 "mov":
                let videoURL = NSURL.fileURL(withPath: path) as URL
                let player = AVPlayer(url: videoURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
                break
            default:
                debugPrint("Webview is loading:" + path)
                let webView = WKWebView(frame: UIScreen.main.bounds)
                webView.navigationDelegate = self
                webView.tag = 1
                let targetURL = NSURL.fileURL(withPath: path)
                webView.loadFileURL(targetURL, allowingReadAccessTo: targetURL)
                stackview.addArrangedSubview(webView)
                break
            }
            display = true
        }
    }

    @IBAction func shareButtonClicked(_ sender: UIButton) {
        let fileToShare = NSURL.fileURL(withPath: path)
            let activityVC = UIActivityViewController(activityItems: [fileToShare], applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = sender.superview
            self.present(activityVC, animated: true, completion: nil)

    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        dump(error)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
