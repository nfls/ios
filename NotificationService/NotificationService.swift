//
//  NotificationService.swift
//  NotificationService
//
//  Created by Qingyang Hu on 2018/7/21.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import UserNotifications
import MobileCoreServices

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            if let callbackToken = bestAttemptContent.userInfo["callbackToken"] as? String {
                let defaultSessionConfiguration = URLSessionConfiguration.default
                let defaultSession = URLSession(configuration: defaultSessionConfiguration)
                let url = URL(string: "https://nfls.io/device/pushCallback")
                var request = URLRequest(url: url!)
                request.httpMethod = "POST"
                let params = ["callbackToken": callbackToken, "type": "client"]
                let data = try! JSONSerialization.data(withJSONObject: params, options: [])
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = data
                let dataTask = defaultSession.dataTask(with: request)
                dataTask.resume()
            }
            if let urlString = bestAttemptContent.userInfo["imageUrl"] as? String, let url = URL(string: urlString), let data = NSData(contentsOf: url) as Data? {
                let path = NSTemporaryDirectory() + "attachment"
                _ = FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
                let file = URL(fileURLWithPath: path)
                var type = kUTTypeJPEG
                if urlString.hasSuffix(".png") {
                    type = kUTTypePNG
                }
                
                let attachment = try! UNNotificationAttachment(identifier: "attachment", url: file, options: [UNNotificationAttachmentOptionsTypeHintKey: type])
                bestAttemptContent.attachments = [attachment]
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
