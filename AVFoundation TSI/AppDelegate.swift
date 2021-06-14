//
//  AppDelegate.swift
//  AVFoundation TSI
//
//  Created by Timo Kilb  on 09.06.21.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        /*
        do {
            try AVAudioSession.sharedInstance().setCategory(.record)
        } catch let error as NSError {
            print("Could not set AudioSession to category record: \(error.localizedDescription)")
        }*/
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = ViewController()
        self.window?.makeKeyAndVisible()
        
        
        return true
    }


}

