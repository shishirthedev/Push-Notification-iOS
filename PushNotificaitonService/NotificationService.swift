//
//  NotificationService.swift
//  PushNotificaitonService
//
//  Created by Developer Shishir on 3/11/19.
//  Copyright © 2019 Shishir's App Studio. All rights reserved.
//

import UserNotifications



class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var downloadTask: URLSessionDownloadTask?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            let userInfo = request.content.userInfo;
            
            // bestAttemptContent.title = userInfo["title"] as! String
            // bestAttemptContent.body = userInfo["message"] as! String
            var urlString:String?
            
            if let imageUrl = userInfo["image-url"]{
                urlString = imageUrl as? String
            }else{
                contentHandler(bestAttemptContent)
                return
            }
            
            handleAttachmentDownload(content: bestAttemptContent.userInfo, urlString: urlString!)
        }
    }
    
    
    func handleAttachmentDownload(content: [AnyHashable : Any], urlString: String) {
        
        guard let url = URL(string: urlString) else {
            // Cannot create a valid URL, return early.
            self.contentHandler!(self.bestAttemptContent!)
            return
        }
        
        self.downloadTask = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            
            if let location = location {
                let fileType = self.determineFileType(fileType: (response?.mimeType)!)
                let fileName = location.lastPathComponent.appending(fileType)
                
                let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
                do {
                    try FileManager.default.moveItem(at: location, to: temporaryDirectory)
                    let attachment = try UNNotificationAttachment(identifier: "", url: temporaryDirectory, options: nil)
                    
                    self.bestAttemptContent?.attachments = [attachment];
                    self.contentHandler!(self.bestAttemptContent!);
                    // The file should be removed automatically from temp
                    // Delete it manually if it is not
                    if FileManager.default.fileExists(atPath: temporaryDirectory.path) {
                        try FileManager.default.removeItem(at: temporaryDirectory)
                    }
                } catch {
                    self.contentHandler!(self.bestAttemptContent!);
                    return;
                }
            }else{
                self.contentHandler!(self.bestAttemptContent!)
            }
        }
        
        self.downloadTask?.resume()
    }
    
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    func determineFileType(fileType: String) -> String {
        // Determines the file type of the attachment to append to URL.
        if fileType == "image/jpeg" {
            return ".jpg";
        }
        if fileType == "image/gif" {
            return ".gif";
        }
        if fileType == "image/png" {
            return ".png";
        } else {
            return ".tmp";
        }
    }
}
