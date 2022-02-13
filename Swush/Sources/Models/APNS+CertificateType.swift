//
//  APNS+CertificateType.swift
//  Swush
//
//  Created by Quentin Eude on 08/02/2022.
//

import Foundation

extension APNS {
    enum CertificateType: CaseIterable, Hashable {
        case p12(certificate: SecIdentity?)
        case p8(tokenFilename: String, teamId: String, keyId: String)
        
        static var allCases: [APNS.CertificateType] = [.p12(certificate: nil), .p8(tokenFilename: "", teamId: "", keyId: "")]
        static var allRawCases: [String] = allCases.map { $0.rawValue }
        
        var isEmptyOrNil: Bool {
            switch self {
            case .p12(let certificate): return certificate == nil
            case .p8(let tokenFilename, let teamId, let keyId): return tokenFilename.isEmpty || teamId.isEmpty || keyId.isEmpty
            }
        }
        
        var rawValue: String {
            switch self {
                case .p12: return "p12"
                case .p8: return "p8"
            }
        }

        static func placeholder(for rawValue: String) -> String {
            switch rawValue {
                case "p12" : return "🎫 Certificate"
                case "p8": return "🔑 Key"
                default: return ""
            }
        }
    }
}
