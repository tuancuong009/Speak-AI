//
//  XORKeyManager.swift
//  Einstein AI
//
//  Created by QTS Coder on 23/5/25.
//

import Foundation
class XORKeyManager {
    static let shared = XORKeyManager()
    func xorEncrypt(_ input: String, key: String) -> String {
        let inputBytes = Array(input.utf8)
        let keyBytes = Array(key.utf8)
        let encryptedBytes = inputBytes.enumerated().map { i, byte in
            byte ^ keyBytes[i % keyBytes.count]
        }
        return Data(encryptedBytes).base64EncodedString()
    }

    func xorDecrypt(_ base64: String, key: String) -> String {
        guard let data = Data(base64Encoded: base64) else { return "" }
        let encryptedBytes = Array(data)
        let keyBytes = Array(key.utf8)
        let decryptedBytes = encryptedBytes.enumerated().map { i, byte in
            byte ^ keyBytes[i % keyBytes.count]
        }
        return String(bytes: decryptedBytes, encoding: .utf8) ?? ""
    }
}
