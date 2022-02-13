//
//  AppState+Commands.swift
//  Swush
//
//  Created by Quentin Eude on 06/02/2022.
//

import Foundation

extension AppState {
    func create() async {
        do {
            var apns = APNS.new
            try await AppDatabase.shared.saveAPNS(&apns)
            selectedApns = apns
            startRenaming(apns)
        } catch {
            print(error)
        }
    }

    func save() async {
        do {
            var apns = APNS(
                id: selectedApns?.id,
                name: selectedApns?.name ?? "",
                creationDate: selectedApns?.creationDate ?? Date(),
                updateDate: Date(),
                certificateType: selectedCertificateType,
                rawPayload: payload,
                deviceToken: deviceToken,
                topic: selectedTopic,
                payloadType: selectedPayloadType,
                priority: priority,
                isSandbox: selectedIdentityType == .sandbox
            )
            try await AppDatabase.shared.saveAPNS(&apns)
        } catch {
            print(error)
        }
    }
}
