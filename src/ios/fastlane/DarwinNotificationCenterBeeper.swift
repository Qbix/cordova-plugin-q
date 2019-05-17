//
//  DarwinNotificationCenterBeeper.swift
//  Yang2020
//
//  Created by adventis on 5/18/19.
//

import Foundation

typealias BeepHandler = () -> Void


@objc class BeeperConstants: NSObject {
    @objc static let reload = "BeepResetApp"
    @objc static let prefix = "net.mxpr.utils.beeper"
}

protocol Beeper {
    
    /// Trigger a beep for the specified identifier
    func beep(identifier: String)
    
    /// Registers a beep handler for a specific identifier.
    /// Upon receiving a "beep" with the matching identifier
    /// the handler is performed
    func register(identifier: String, handler: @escaping BeepHandler)
    
    /// Unregister a beep handler for a specific identifier.
    /// Further "beeps" for this identifier will not
    /// cause the previously registered handler to be called
    func unregister(identifier: String)
}

@objc class DarwinNotificationCenterBeeper: NSObject,Beeper {
    
    private let darwinNotificationCenter: CFNotificationCenter
    private let prefix: String
    private var handlers = [String: BeepHandler]()
    
    @objc init(prefix: String = BeeperConstants.prefix) {
        darwinNotificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        self.prefix = prefix.appending(".")
    }
    
    deinit {
        CFNotificationCenterRemoveObserver(darwinNotificationCenter,
                                           rawPointerToSelf,
                                           nil,
                                           nil)
        
    }
    
    private func notificationName(from identifier: String) -> String {
        return "\(prefix)\(identifier)"
    }
    
    private func identifier(from name: String) -> String {
        guard let prefixRange = name.range(of: prefix) else {
            return name
        }
        return String(name[prefixRange.upperBound...])
    }
    
    fileprivate func handleNotification(name: String) {
        let handlerIdentifier = identifier(from: name)
        if let handler = handlers[handlerIdentifier] {
            handler()
        }
    }
    
    private var rawPointerToSelf: UnsafeRawPointer {
        return UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
    }
    
    // MARK: - Beeper
    
    func beep(identifier: String) {
        let name = notificationName(from: identifier)
        CFNotificationCenterPostNotification(darwinNotificationCenter,
                                             CFNotificationName(name as CFString),
                                             nil,
                                             nil,
                                             true)
    }
    
    @objc func register(identifier: String, handler: @escaping BeepHandler) {
        handlers[identifier] = handler
        let name = notificationName(from: identifier)
        CFNotificationCenterAddObserver(darwinNotificationCenter,
                                        rawPointerToSelf,
                                        handleDarwinNotification,
                                        name as CFString,
                                        nil,
                                        .deliverImmediately)
        
    }
    
    func unregister(identifier: String) {
        handlers[identifier] = nil
        let name = notificationName(from: identifier)
        let cfNotificationName = CFNotificationName(name as CFString)
        CFNotificationCenterRemoveObserver(darwinNotificationCenter,
                                           rawPointerToSelf,
                                           cfNotificationName,
                                           nil)
    }
}

fileprivate func handleDarwinNotification(notificationCenteR: CFNotificationCenter?,
                                          observer: UnsafeMutableRawPointer?,
                                          notificationName: CFNotificationName?,
                                          unusedObject: UnsafeRawPointer?,
                                          unusedUserInfo: CFDictionary?) -> Void {
    guard let observer = observer,
        let notificationName = notificationName else {
            return
    }
    let beeper = Unmanaged<DarwinNotificationCenterBeeper>.fromOpaque(observer).takeUnretainedValue()
    let name = (notificationName.rawValue as String)
    beeper.handleNotification(name: name)
}
