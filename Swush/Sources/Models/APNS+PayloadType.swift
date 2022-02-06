//
//  APNS+PayloadType.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import Foundation

extension APNS {
    enum PayloadType: String, Codable, CaseIterable {
        case alert
        case background
        case voip
        case complication
        case fileprovider
        case mdm

        private static let mapping: [PayloadType: String] = [
            .alert: "Alert",
            .background: "Background",
            .voip: "Voip",
            .complication: "Complication",
            .fileprovider: "File Provider",
            .mdm: "Mdm",
        ]

        static func from(value: PayloadType) -> String {
            mapping[value] ?? "Unknown"
        }
    }
}
