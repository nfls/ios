//
//  NotificationService.swift
//  pushNotification
//
//  Created by hqy on 2017/11/5.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if let bestAttemptContent = bestAttemptContent {
            if let urlString = bestAttemptContent.userInfo["imageUrl"] as? String, let data = NSData(contentsOf: URL(string:urlString)!) as Data? {
                let path = NSTemporaryDirectory() + "attachment"
                _ = FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
                do {
                    let file = URL(fileURLWithPath: path)
                    let attachment = try UNNotificationAttachment(identifier: "attachment", url: file,options:[UNNotificationAttachmentOptionsTypeHintKey : "public.jpeg"])
                    bestAttemptContent.attachments = [attachment]
                } catch {}
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
