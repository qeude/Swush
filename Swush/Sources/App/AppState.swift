//
//  AppState.swift
//  Swush
//
//  Created by Quentin Eude on 01/02/2022.
//

import Foundation
import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var showDeleteAlert: Bool = false
    @Published var apnsToDelete: APNS? = nil

    @Published var apnsToRename: APNS? = nil
    @Published var newName: String = ""
    
    @Published var canCreateNewApns: Bool = true
    @Published var canRenameApns: Bool = true
    
    @Published var selectedApnsId: Int64? = nil
    
    func selectionBindingForId(id: Int64?) -> Binding<Bool> {
            Binding<Bool> { () -> Bool in
                self.selectedApnsId == id
            } set: { (newValue) in
                if newValue {
                    self.selectedApnsId = id
                }
            }

        }
    
    func startRenaming(_ apns: APNS) {
        newName = apns.name
        apnsToRename = apns
        canCreateNewApns = false
        canRenameApns = false
    }
    
    func performRenaming() async {
        if let apnsToRename = apnsToRename,
           !newName.isEmpty {
            await save(apns: apnsToRename, with: newName)
        }
        self.apnsToRename = nil
        newName = ""
        canCreateNewApns = true
        canRenameApns = true
    }
    
    func showDeleteAlert(for apns: APNS) {
        apnsToDelete = apns
        showDeleteAlert = true
    }
    
    func delete(apns: APNS) async {
        guard let id = apns.id else { return }
        do {
            try await AppDatabase.shared.deleteAPNS(ids: [id])
            apnsToDelete = nil
        } catch {
            print(error)
        }
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
                            isSandbox: apns.isSandbox)
            try await AppDatabase.shared.saveAPNS(&apns)
        } catch {
            print(error)
        }
    }
    
    func create() async {
        do {
            var apns = APNS.new
            try await AppDatabase.shared.saveAPNS(&apns)
            selectedApnsId = apns.id
            startRenaming(apns)
        } catch {
            print(error)
        }
    }
}
