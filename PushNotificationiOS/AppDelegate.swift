//
//  AppDelegate.swift
//  PushNotificationiOS
//
//  Created by Developer Shishir on 3/8/19.
//  Copyright © 2019 Shishir's App Studio. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerForPushNotifications()
        
        
        //        if let instanceIdToken = InstanceID.instanceID().instanceID(handler: resu)() {
        //            print("Device token which is good to use with FCM \(instanceIdToken)")
        //        }else{
        //            print("///////////////// No Id fouond")
        //        }
        
        
        // If the app was not running and user launched the app by tapping on notification...
        let notificationOption = launchOptions?[.remoteNotification]
        if let _ = notificationOption as? [String: AnyObject]{
            showAlertAppDelegate(title: "launch option", message: "sjfksjlfks")
            
            //            let aps = notification["aps"] as? [String: AnyObject] {
            //            print(aps)
        }
        
        
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func tokenRefreshNotification(){
        
    }
    
    
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func registerForPushNotifications() {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            
            UNUserNotificationCenter.current().delegate = self
            
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if (settings.authorizationStatus == .authorized){
                    DispatchQueue.main.async {
                        if !UIApplication.shared.isRegisteredForRemoteNotifications{
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }else if (settings.authorizationStatus == .notDetermined){
                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                    UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {
                        [weak self] (granted, error) in
                        guard granted else{
                            self?.showPermissionAlert()
                            return
                        }
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    })
                }else if (settings.authorizationStatus == .denied){
                    self.showPermissionAlert()
                }
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            DispatchQueue.main.async {
                UIApplication.shared.registerUserNotificationSettings(settings)
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //        print("Successfully registered for remote notifications")
        //        var readableToken: String = ""
        //        for i in 0..<deviceToken.count {
        //            readableToken += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        //        }
        //        print("NOTIFICATION/PUSH - Received an APNs device token: \(readableToken)")
        Messaging.messaging().apnsToken = deviceToken
        //        InstanceID.instanceID().instanceID { (result, error) in
        //            if let res = result{
        //                print("/////////////////Remote instance ID token: \(res.token)")
        //            }else if let err = error{
        //                print("///////////Error fetching remote instange ID: \(err.localizedDescription)")
        //            }
        //        }
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
    }
    
    
    func showPermissionAlert() {
        let alert = UIAlertController(title: "WARNING", message: "Please enable access to Notifications in the Settings app.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) {[weak self] (alertAction) in
            self?.gotoAppSettings()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func gotoAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if(UIApplication.shared.canOpenURL(settingsUrl)){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl)
            } else {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
}


extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("//////////////////// FCM TOKEN: \(fcmToken)")
        // Send this fcm token to server to send push notification..............
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("///////////////////////////Remote Message: \(remoteMessage.appData)")
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        // FCM token updated, update it on Backend Server
        print("Firebase registration token refreshed: \(fcmToken)")
    }
    
    
    
    // This method is called if the app running either in background or foreground.....
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //        print("Second One Called/////////////////////////////")
        //
        //        guard let _ = userInfo["aps"] as? NSDictionary else { return }
        //        if let title = userInfo["title"] as? String, let message = userInfo["message"] as? String,
        //            let notificationId = userInfo[gcmMessageIDKey] as? String{
        //            let appState: UIApplication.State = UIApplication.shared.applicationState
        //            switch appState{
        //            case .active:
        //                print("///////////// Foreground")
        //                self.showAlertAppDelegate(title: title, message: message)
        //                break
        //
        //            default:
        //                print("............ Bakcground")
        //                NotificationUtils.sharedInstance.showNotification(title: title, msg: message, msgId: notificationId)
        //                break
        //            }
        //        }
        let appState: UIApplication.State = UIApplication.shared.applicationState
        if #available(iOS 10.0, *){
            // Nothing to do..................
        }else{
            print(UIDevice.current.systemVersion)
            if appState == .active{
                if let apps = userInfo["aps"] as? [String : AnyObject]{
                    if let alert = apps["alert"] as? [String : AnyObject]{
                        if let title = alert["title"] as? String, let message = alert["body"] as? String{
                            showAlertAppDelegate(title: title, message: message)
                        }
                    }
                }
            }
        }
        completionHandler(.newData)
    }
    
    
    // Firebase notification received
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // print(" ////////////////////////// didReceive response: \(response)")
        
        //let content = response.notification.request.content
        //self.showAlertAppDelegate(title: content.title, message: content.body)
        completionHandler()
    }
    
    
    func showAlertAppDelegate(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.window?.rootViewController?.present(alert, animated: false, completion: nil)
    }
}


