//
//  APNSSecIdentityType.swift
//  Swush
//
//  Created by Quentin Eude on 26/01/2022.
//

import Foundation


struct SecIdentityService {
    var identities: [SecIdentity]? {
        let query: [String: Any] = [kSecClass as String: kSecClassIdentity,
                     kSecMatchLimit as String: kSecMatchLimitAll,
                     kSecReturnRef as String: kCFBooleanTrue,]
        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)
        
        guard status != errSecItemNotFound else {
//                throw KeychainError.itemNotFound
            return nil
        }
        let result = itemCopy as? [SecIdentity] ?? []
    
        return result.filter { identity in
            return identity.type != .invalid
        }
    }
}
