//
//  TempStorage.swift
//  Speak-AI
//
//  Created by QTS Coder on 11/4/25.
//


class TempStorage {
    static let shared = TempStorage()
    private init() {}

    var folderObj: FolderObj?
    var isPremium = InApPurchaseManager.shared.isPremiumActive
    var isCheckInApp = false
}
