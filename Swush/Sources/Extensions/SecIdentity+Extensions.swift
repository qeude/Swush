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
    if values?[SecIdentityType.sandbox.rawValue] != nil
      && values?[SecIdentityType.production.rawValue] != nil
    {
      return .universal
    } else if values?[SecIdentityType.sandbox.rawValue] != nil {
      return .sandbox
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
      SecIdentityType.sandbox.rawValue,
      SecIdentityType.production.rawValue,
      SecIdentityType.universal.rawValue,
      kSecOIDInvalidityDate as String,
    ]
    let values = SecCertificateCopyValues(certificate!, keys as CFArray, nil)

    certificate = nil
    return values as? [String: AnyObject]
  }

  var topics: [String] {
    let values = self.values
    if values?[SecIdentityType.sandbox.rawValue] != nil
      && values?[SecIdentityType.production.rawValue] != nil
    {
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

  var expiryDate: Date? {
    let values = self.values
    if values?[kSecOIDInvalidityDate as String] != nil {
      if let content = values?[kSecOIDInvalidityDate as String] {
        return content["value"] as? Date
      }
    }
    return nil
  }

  var name: String? {
    var certificate: SecCertificate?
    var name: CFString?
    SecIdentityCopyCertificate(self, &certificate)
    SecCertificateCopyCommonName(certificate!, &name)
    guard let name = name else { return nil }
    return name as String
  }

  var humanReadable: String {
    var dateString = ""
    if let expiryDate = expiryDate {
      let formatter = DateFormatter()
      formatter.dateStyle = .short
      formatter.timeStyle = .short
      dateString = formatter.string(from: expiryDate)
    }
    return "🎟 \(name ?? "") (\(SecIdentityType.formattedString(for: self.type))) - 🚮 \(dateString)"
  }
}
