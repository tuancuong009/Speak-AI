//
//  InternetChecker.swift
//  Speak-AI
//
//  Created by QTS Coder on 10/4/25.
//


import Network

class InternetChecker {
    static func isConnected(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetCheck")

        monitor.pathUpdateHandler = { path in
            monitor.cancel() // Dừng sau khi check
            DispatchQueue.main.async {
                completion(path.status == .satisfied)
            }
        }

        monitor.start(queue: queue)
    }
}
