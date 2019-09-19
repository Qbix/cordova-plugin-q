//
//  QbixAppGroupManager.swift
//  BusinessCardsScan
//
//  Created by Igor on 10/29/18.
//

import Foundation

class QbixAppGroupManager:NSObject {
    struct keys {
        static let Name = "Name";
        static let LastOpen = "LastOpen";
        static let InstallTime = "InstallTime";
    }
    
    let appGroupId = "group.qbix.apps";
    let sharedUserDefaults:UserDefaults;
    
    let appBundleID:String
    let installTime:Int64
    
    @objc convenience init(appBundleID:String) {
        self.init(appBundleID: appBundleID, installTime: 0)
    }
    
    @objc init(appBundleID:String, installTime:Int64) {
        self.sharedUserDefaults = UserDefaults.init(suiteName: appGroupId)!
        self.appBundleID = appBundleID;
        self.installTime = installTime;
    }
    
    @objc func initApp() {
        var appInfo = Dictionary<String, Any>.init();
        let lastOpen = Date.init().timeIntervalSince1970;
        let appName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
//        let appName = Bundle.init(identifier: "BundleIdentifier")?.object(forInfoDictionaryKey: kCFBundleExecutableKey as String)


        if(self.sharedUserDefaults.dictionary(forKey: self.appBundleID) != nil) {
            appInfo = self.sharedUserDefaults.dictionary(forKey: self.appBundleID)!;
        } else {
            appInfo[QbixAppGroupManager.keys.InstallTime] = Date.init().timeIntervalSince1970
        }
        
        appInfo[QbixAppGroupManager.keys.LastOpen] = lastOpen
        appInfo[QbixAppGroupManager.keys.Name] = appName
        if(self.installTime != 0) {
            appInfo[QbixAppGroupManager.keys.InstallTime] = self.installTime
        }
        
        self.sharedUserDefaults.set(appInfo, forKey: self.appBundleID)
    }
    
    @objc func isAppInstalled(appBundleID:String) -> Bool {
        return self.sharedUserDefaults.dictionary(forKey: appBundleID) != nil
    }

    @objc func getApp(appBundleID:String) -> Dictionary<String,Any>? {
        return self.sharedUserDefaults.dictionary(forKey: appBundleID)
    }
}
