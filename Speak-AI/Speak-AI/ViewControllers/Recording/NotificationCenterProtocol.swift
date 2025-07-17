//
//  NotificationCenterProtocol.swift
//  Speak-AI
//
//  Created by QTS Coder on 10/2/25.
//


public typealias Observer = (_ name: String, _ data: Any) -> Void

protocol NotificationCenterProtocol{
    func addObserver(forName name: String, usingBlock block: @escaping Observer)
    func removeObserver(forName name: String)
}
