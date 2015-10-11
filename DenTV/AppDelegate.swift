//
//  AppDelegate.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 11.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        configureAppearance()
        propagateContext()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        coreDataStack.saveContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        coreDataStack.saveContext()
    }

    // MARK: - Helpers
    func configureAppearance() {
        if let tabBarController = window?.rootViewController as? UITabBarController {
            let tabBar = tabBarController.tabBar
            let bgView = UIView(frame: CGRectMake(0, 0, (window?.frame.width)!, tabBar.frame.height))
            bgView.backgroundColor = UIColor.blackColor()
            tabBar.insertSubview(bgView, atIndex: 0)
        }
        UITabBar.appearance().tintColor = UIColor.yellowColor()
    }

    func propagateContext() {
        if let tabBarController = window?.rootViewController as? UITabBarController {
            if let controller = tabBarController.viewControllers?.first as? HomeViewController {
                controller.managedContext = coreDataStack.context
            }
            if let nav_controller = tabBarController.viewControllers?[1] as? UINavigationController {
                if let controller = nav_controller.topViewController as? PlaylistsViewController {
                    controller.managedContext = coreDataStack.context
                }
            }
            if let nav_controller = tabBarController.viewControllers?[2] as? UINavigationController {
                if let controller = nav_controller.topViewController as? PlaylistsViewController {
                    controller.managedContext = coreDataStack.context
                }
            }
        }
    }
}

