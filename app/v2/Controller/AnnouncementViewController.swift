//
//  AnnouncementViewController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 01/04/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import UIKit
import MarkdownView
import SafariServices

class AnnouncementViewController: UIViewController {

    var text: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let mdView = MarkdownView()
        view.addSubview(mdView)
        mdView.translatesAutoresizingMaskIntoConstraints = false
        mdView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
        mdView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mdView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mdView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        mdView.onTouchLink = { url in
            let controller = SFSafariViewController(url: url.url!)
            self.present(controller, animated: true, completion: nil)
            return false
        }
        mdView.load(markdown: text, enableImage: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
