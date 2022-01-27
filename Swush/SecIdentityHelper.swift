//
//  APNSSecIdentityType.swift
//  Swush
//
//  Created by Quentin Eude on 26/01/2022.
//

import Foundation


struct SecIdentityHelper {
    enum SecIdentityType: String {
        case invalid
        case development = "1.2.840.113635.100.6.3.1"
        case production = "1.2.840.113635.100.6.3.2"
        case universal = "1.2.840.113635.100.6.3.6"
    }
    
    static var identities: [SecIdentity]? {
        let query: [String: Any] = [kSecClass as String: kSecClassIdentity,
                     kSecMatchLimit as String: kSecMatchLimitAll,
                     kSecReturnRef as String: kCFBooleanTrue]
        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)
        
        guard status != errSecItemNotFound else {
//                throw KeychainError.itemNotFound
            return nil
        }
        let result = itemCopy as? [SecIdentity] ?? []
    
        return result.filter { identity in
            let type = SecIdentityHelper.apnsSecIdentiyGetType(for: identity)
            return type != .invalid
        }
    }
    
    static func apnsSecValues(for identity: SecIdentity) -> [String: AnyObject]? {
        var certificate: SecCertificate?
        SecIdentityCopyCertificate(identity, &certificate)
        let keys = [
            SecIdentityType.development.rawValue,
            SecIdentityType.production.rawValue,
            SecIdentityType.universal.rawValue,
        ]
        let values = SecCertificateCopyValues(certificate!, keys as CFArray, nil)
        
        certificate = nil
        return values as? [String: AnyObject]
        
    }


    static func apnsSecIdentiyGetType(for identity: SecIdentity) -> SecIdentityType {
        let values = apnsSecValues(for: identity)
        if values?[SecIdentityType.development.rawValue] != nil && values?[SecIdentityType.production.rawValue] != nil {
            return .universal
        } else if values?[SecIdentityType.development.rawValue] != nil {
            return .development
        } else if values?[SecIdentityType.production.rawValue] != nil {
            return .production
        } else {
            return .invalid
        }
    }
    
    static func apnsSecIdentityGetTopics(for identity: SecIdentity) -> [String] {
        let values = apnsSecValues(for: identity)
        if values?[SecIdentityType.development.rawValue] != nil && values?[SecIdentityType.production.rawValue] != nil {
            if let topicContents = values?[SecIdentityType.universal.rawValue] {
                let topicArray: [[String: Any]] = topicContents["value"] as? [[String: Any]] ?? []
                return topicArray.compactMap { topic in
                    if topic["label"] as? String == "Data" {
                        return topic["value"] as? String
                    }
                    return nil
                }
            }
        }
        return []
    }
}
