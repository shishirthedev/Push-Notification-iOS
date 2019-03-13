//
//  NotificationUtils.swift
//  PushNotificationiOS
//
//  Created by Developer Shishir on 3/11/19.
//  Copyright © 2019 Shishir's App Studio. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationUtils {
    
    static let sharedInstance: NotificationUtils = NotificationUtils()
    private  init() {}
    
    func showNotification( title: String, msg: String, msgId: String){
        
        if #available(iOS 10.0, *){
            let content = UNMutableNotificationContent()
            content.title = title
            content.body =  msg
            content.sound = UNNotificationSound.default
            // Deliver the notification in 60 seconds.let attachement = try? UNNotificationAttachment(identifier: "attachment", url: fileURL, options: nil)
            let fileURL =  Bundle.main.url(forResource: "tisha", withExtension: "jpg")
            let attachement = try? UNNotificationAttachment(identifier: "attachment", url: fileURL!, options: nil)
            content.attachments = [attachement!]
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 60.0, repeats: false)
            let request = UNNotificationRequest.init(identifier: msgId, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            
        }else{
            let localNotification = UILocalNotification()
            localNotification.alertTitle = title
            localNotification.alertBody = msg
            localNotification.fireDate = Date()
            localNotification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }
}
