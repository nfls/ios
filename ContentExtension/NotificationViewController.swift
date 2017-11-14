//
//  NotificationViewController.swift
//  ContentExtension
//
//  Created by hqy on 2017/11/9.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet var body: UILabel!
    @IBOutlet var label: UILabel!
    @IBOutlet weak var image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        label.text = notification.request.content.title
        label.sizeToFit()
        body.text = notification.request.content.body
        body.lineBreakMode = .byWordWrapping
        body.numberOfLines = 0
        body.sizeToFit()
    }

}
