//
//  AppState+Send.swift
//  Swush
//
//  Created by Quentin Eude on 06/02/2022.
//

import Foundation

extension AppState {
    func sendPush() async {
        guard let _ = payload.toJSON() else {
            errorMessage = "Please provide a valid JSON payload."
            showErrorMessage = true
            return
        }
        switch selectedCertificateType {
        case .p8(let filename, _, _):
            if !FileManager.default.fileExists(atPath: filename) {
                errorMessage = "Please provide a valid .p8 token."
                showErrorMessage = true
                return
            }
        case .keychain: break
        }
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
            isSandbox: selectedIdentityType == .sandbox,
            collapseId: collapseId,
            notificationId: notificationId,
            expiration: expiration
        )
        do {
            try await DependencyProvider.apnsService.sendPush(for: apns)
        } catch let error as APNSService.APIError {
            print(error)
            errorMessage = error.description
            showErrorMessage = true
        } catch {
            print(error)
        }
        
    }
    
    private func sendPushWithApnsToken() {
        
    }
    
    private func sendPushWithApnsCertificate() {
        
    }
}
