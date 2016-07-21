//
//  AppDelegate.swift
//  FcmExample
//
//  Created by Leo Wang on 2016-07-19.
//  Copyright © 2016 DDS. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        FIRApp.configure()
        
        registerForPushNotifications(application)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onTokenRefresh), name: kFIRInstanceIDTokenRefreshNotification, object: nil)
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject] {
            handleNotificationPayload(notification)
        }
        return true
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // Let FCM know about the message for analytics etc.
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        // handle your message
        handleNotificationInBackground(userInfo)
//        if application.applicationState == .Background {
//            completionHandler(.NoData)
//        } else {
            handleNotificationPayload(userInfo)
            completionHandler(.NewData)
//        }
    }
    
        // MARK: Helper
    func onTokenRefresh() {
        if let token = FIRInstanceID.instanceID().token() {
            print("onTokenRefresh: " + token)
        } else {
            print("token is nil")
        }
    }
    
    func handleNotificationInBackground(payload: [NSObject : AnyObject]) -> Void {
        print(payload)
        print("***Background work***")
    }
    
    func handleNotificationPayload(payload: [NSObject : AnyObject]) -> Void {
        if let aps = payload["aps"] as? [String : AnyObject],
            let alert = aps["alert"] as? [String : AnyObject] {
            print("***Updating ui***")
            
            let title = alert["title"] as? String
            let body = alert["body"] as?  String
            
            let alertController = UIAlertController(title: title ?? "A title", message: body ?? "Hello, world!", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: Notification registration
extension AppDelegate {
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)
        
        //Tricky line
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Sandbox)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error.localizedDescription)
    }
}

