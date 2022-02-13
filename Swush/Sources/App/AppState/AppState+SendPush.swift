//
//  AppState+Send.swift
//  Swush
//
//  Created by Quentin Eude on 06/02/2022.
//

import Foundation

extension AppState {
    func sendPush() async throws {
        guard let _ = payload.toJSON(), !selectedCertificateType.isEmptyOrNil else { return }
        let apns = APNS(
            name: name,
            creationDate: selectedApns?.creationDate ?? Date(),
            updateDate: selectedApns?.updateDate ?? Date(),
            certificateType: selectedCertificateType,
            rawPayload: payload,
            deviceToken: deviceToken,
            topic: selectedTopic,
            payloadType: selectedPayloadType,
            priority: priority,
            isSandbox: selectedIdentityType == .sandbox
        )
        try await DependencyProvider.apnsService.sendPush(for: apns)
    }
    
    private func sendPushWithApnsToken() {
        
    }
    
    private func sendPushWithApnsCertificate() {
        
    }
}
