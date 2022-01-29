//
//  SecIdentity+Extensions.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import Foundation
import SecurityInterface

extension SecIdentity {
    var type: SecIdentityType {
        let values = self.values
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
    
    var values: [String: AnyObject]? {
        var certificate: SecCertificate?
        SecIdentityCopyCertificate(self, &certificate)
        let keys = [
            SecIdentityType.development.rawValue,
            SecIdentityType.production.rawValue,
            SecIdentityType.universal.rawValue,
        ]
        let values = SecCertificateCopyValues(certificate!, keys as CFArray, nil)
        
        certificate = nil
        return values as? [String: AnyObject]
    }
    
    var topics: [String] {
        let values = self.values
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
    
    var humanReadable: String {
        return self.topics.first ?? "Unknown"
    }
}
