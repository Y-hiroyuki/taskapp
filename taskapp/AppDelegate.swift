//
//  AppDelegate.swift
//  taskapp
//
//  Created by 由上博之 on 2021/05/24.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
      //アプリの起動時と終了時にのみ呼ばれる

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
          //アプリ起動時に呼ばれるメソッド
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert,.sound]){ (granted, error) in
        }
        center.delegate = self
          //今回追加
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
          //今回追加
        completionHandler([.banner, .list, .sound])}
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
          //アプリが終了した時に呼ばれるメソッド
    }

