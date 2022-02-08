//
//  APNS+CertificateType.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import Foundation

extension APNS {
    enum IdentityType: CaseIterable {
        case sandbox
        case production

        private static let mapping: [IdentityType: String] = [
            .sandbox: "Sandbox",
            .production: "Production",
        ]

        private static let slugMapping: [IdentityType: String] = [
            .sandbox: "sandbox",
            .production: "production",
        ]

        var slug: String {
            IdentityType.slugMapping[self] ?? ""
        }

        static func from(value: IdentityType) -> String {
            mapping[value] ?? "Unknown"
        }
    }
}
