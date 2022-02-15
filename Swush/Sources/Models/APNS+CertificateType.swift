//
//  APNS+CertificateType.swift
//  Swush
//
//  Created by Quentin Eude on 08/02/2022.
//

import Foundation

extension APNS {
    enum CertificateType: CaseIterable, Hashable {
        case keychain(certificate: SecIdentity?)
        case p8(filepath: String, teamId: String, keyId: String)
        
        static var allCases: [APNS.CertificateType] = [.keychain(certificate: nil), .p8(filepath: "", teamId: "", keyId: "")]
        static var allRawCases: [String] = allCases.map { $0.rawValue }
        
        var isEmptyOrNil: Bool {
            switch self {
            case .keychain(let certificate): return certificate == nil
            case .p8(let filepath, let teamId, let keyId): return filepath.isEmpty || teamId.isEmpty || keyId.isEmpty
            }
        }
        
        var rawValue: String {
            switch self {
                case .keychain: return "keychain"
                case .p8: return "p8"
            }
        }

        static func placeholder(for rawValue: String) -> String {
            switch rawValue {
                case "keychain" : return "🎫 Certificate"
                case "p8": return "🔑 Key"
                default: return ""
            }
        }
    }
}
