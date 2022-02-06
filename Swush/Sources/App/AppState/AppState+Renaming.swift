//
//  AppState+Renaming.swift
//  Swush
//
//  Created by Quentin Eude on 06/02/2022.
//

import Foundation

extension AppState {
    func startRenaming(_ apns: APNS) {
        newName = apns.name
        apnsToRename = apns
        canCreateNewApns = false
        canRenameApns = false
    }

    func performRenaming() async {
        if let apnsToRename = apnsToRename,
           !newName.isEmpty
        {
            await save(apns: apnsToRename, with: newName)
        }
        apnsToRename = nil
        newName = ""
        canCreateNewApns = true
        canRenameApns = true
    }

    private func save(apns: APNS, with newName: String) async {
        do {
            var apns = APNS(
                id: apns.id,
                name: newName,
                creationDate: apns.creationDate,
                updateDate: Date(),
                identityString: apns.identityString,
                rawPayload: apns.rawPayload,
                token: apns.token,
                topic: apns.topic,
                payloadType: apns.payloadType,
                priority: apns.priority,
                isSandbox: apns.isSandbox
            )
            try await AppDatabase.shared.saveAPNS(&apns)
            selectedApns = apns
        } catch {
            print(error)
        }
    }
}
