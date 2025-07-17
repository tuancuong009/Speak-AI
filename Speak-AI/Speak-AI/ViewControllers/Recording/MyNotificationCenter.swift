//
//  MyNotificationCenter.swift
//  Speak-AI
//
//  Created by QTS Coder on 10/2/25.
//


class MyNotificationCenter: NotificationCenterProtocol {
    
    var observers = [String: [Observer]]()
    
    func addObserver(forName name: String, usingBlock block: @escaping Observer) {
        if (observers.keys.contains(name)) {
            observers[name]?.append(block)
        } else {
            observers[name] = [block]
        }
    }
    
    func removeObserver(forName name: String) {
            observers[name] = nil
    }
    
    func postNotification(forName name: String, forData data: Any) {
        // For each object in the observer array, call its processNotification() method
        if let observerForName = observers[name] {
            for observer in observerForName {
                observer(name, data)
            }
        }
    }
}
