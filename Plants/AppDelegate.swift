//
//  AppDelegate.swift
//  Plants
//
//  Created by Reina Iketani on 2023/06/20.
//

import UIKit
import RealmSwift
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate  {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        //通知
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        }
        center.delegate = self
        // アプリで使用するdefault.realmのパスを取得
        let defaultRealmPath = Realm.Configuration.defaultConfiguration.fileURL!

        // 初期データが入ったRealmファイルのパスを取得
        let bundleRealmPath = Bundle.main.url(forResource: "Plants", withExtension: "realm")

        // アプリで使用するRealmファイルが存在しない（= 初回利用）場合は、シードファイルをコピーする
        if !FileManager.default.fileExists(atPath: defaultRealmPath.path) {
           do {
               try FileManager.default.copyItem(at: bundleRealmPath!, to: defaultRealmPath)
           } catch let error {
                print("error: \(error)")
           }
        }
        
        //migration()
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .list, .sound])
        }
    
    //migration
    func migration() {
      // 次のバージョン（現バージョンが０なので、１をセット）
      let nextSchemaVersion = 2

      // マイグレーション設定
      let config = Realm.Configuration(
        schemaVersion: UInt64(nextSchemaVersion),
        migrationBlock: { migration, oldSchemaVersion in
          if (oldSchemaVersion < nextSchemaVersion) {
          }
        })
        Realm.Configuration.defaultConfiguration = config
    }
    
    
    
    
    
    
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

