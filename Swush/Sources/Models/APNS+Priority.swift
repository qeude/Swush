//
//  APNS+Priority.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import Foundation

extension APNS {
    enum Priority: Int, Codable, CaseIterable {
        case low = 5
        case high = 10
    }
}
