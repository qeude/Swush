//
//  APNS.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import Security

struct APNS {
    let identity: SecIdentity
    let payload: [String: Any]
    let token: String
    let topic: String
    let payloadType: PayloadType
    let priority: Priority
    let isSandbox: Bool
}
