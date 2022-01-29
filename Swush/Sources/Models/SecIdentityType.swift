//
//  SecIdentityType.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import Foundation

// http://www.apple.com/certificateauthority/Apple_WWDR_CPS
enum SecIdentityType: String {
    case invalid
    case development = "1.2.840.113635.100.6.3.1"
    case production = "1.2.840.113635.100.6.3.2"
    case universal = "1.2.840.113635.100.6.3.6"
}
