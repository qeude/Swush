//
//  APNS+PayloadType.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import Foundation

extension APNS {
  enum PayloadType: String, Codable, CaseIterable {
    case alert = "alert"
    case background = "background"
    case voip = "voip"
    case complication = "complication"
    case fileprovider = "fileprovider"
    case mdm = "mdm"

    private static let mapping: [PayloadType: String] = [
      .alert: "Alert",
      .background: "Background",
      .voip: "Voip",
      .complication: "Complication",
      .fileprovider: "File Provider",
      .mdm: "Mdm",
    ]

    static func from(value: PayloadType) -> String {
      return mapping[value] ?? "Unknown"
    }
  }

}
