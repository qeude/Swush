//
//  APNS+CertificateType.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import Foundation

extension APNS {
    enum CertificateType: CaseIterable {
        case sandbox
        case production
        
        private static let mapping: [CertificateType: String] = [
            .sandbox: "Sandbox",
            .production: "Production",
        ]
        
        private static let slugMapping: [CertificateType: String] = [
            .sandbox: "sandbox",
            .production: "production",
        ]
        
        var slug: String {
            return CertificateType.slugMapping[self] ?? ""
        }
        
        static func from(value: CertificateType) -> String {
            return mapping[value] ?? "Unknown"
        }
    }
    
    
}
