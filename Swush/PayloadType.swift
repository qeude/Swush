//
//  APNSType.swift
//  Swush
//
//  Created by Quentin Eude on 26/01/2022.
//

import Foundation

enum PayloadType: CaseIterable {
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
    
    private static let slugMapping: [PayloadType: String] = [
        .alert: "alert",
        .background: "background",
        .voip: "voip",
        .complication: "complication",
        .fileprovider: "fileprovider",
        .mdm: "mdm",
    ]
    
    var slug: String {
        return PayloadType.slugMapping[self] ?? ""
    }
    
    static func from(value: PayloadType) -> String {
        return mapping[value] ?? "Unknown"
    }
}
