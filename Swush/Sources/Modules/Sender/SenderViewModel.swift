//
//  SwushViewModel.swift
//  Swush
//
//  Created by Quentin Eude on 26/01/2022.
//

import SwiftUI
import SecurityInterface

class SenderViewModel: ObservableObject {
    @Published var selectedIdentity: SecIdentity? = nil {
        didSet {
            didChooseIdentity()
        }
    }
    @Published var name: String = ""
    @Published var selectedCertificateType: APNS.CertificateType = .sandbox
    @Published var token = ""
    @Published var payload = "{\n\t\"aps\": {\n\t\t\"alert\": \"Push test!\",\n\t\t\"sound\": \"default\",\n\t}\n}"
    @Published var topics: [String] = []
    @Published var priority: APNS.Priority = .high
    @Published var selectedTopic: String = ""
    @Published var showCertificateTypePicker: Bool = false
    @Published var selectedPayloadType: APNS.PayloadType = .alert
    
    let id: Int64
    let creationDate: Date
    let updateDate: Date
    
    init(apns: APNS) {
        selectedIdentity = apns.identity
        selectedCertificateType = apns.isSandbox ? .sandbox : .production
        token = apns.token
        payload = apns.rawPayload
        topics = apns.identity?.topics ?? []
        priority = apns.priority
        selectedTopic = apns.topic
        selectedPayloadType = apns.payloadType
        name = apns.name
        id = apns.id!
        creationDate = apns.creationDate
        updateDate = apns.updateDate
        didChooseIdentity()
    }
    
    func didChooseIdentity() {
        guard let selectedIdentity = selectedIdentity else {
            topics = []
            selectedTopic = ""
            return
        }
        let type = selectedIdentity.type
        switch type {
            case .universal:
                showCertificateTypePicker = true
            case .production:
                selectedCertificateType = .production
            default:
                break
        }
        
        topics = selectedIdentity.topics
        selectedTopic = topics.first ?? ""
    }
    
    func sendPush() async throws {
        guard let _ = payload.toJSON(), let identity = selectedIdentity else { return }
        let apns = APNS(name: name, creationDate: creationDate, updateDate: updateDate, identityString: identity.humanReadable, rawPayload: payload, token: token, topic: selectedTopic, payloadType: selectedPayloadType, priority: priority, isSandbox: selectedCertificateType == .sandbox)
        try await DependencyProvider.apnsService.sendPush(for: apns)
    }
    
    func save() async {
        do {
            var apns = APNS(
                            id: id,
                            name: name,
                            creationDate: creationDate,
                            updateDate: updateDate,
                            identityString: selectedIdentity!.humanReadable,
                            rawPayload: payload,
                            token: token,
                            topic: selectedTopic,
                            payloadType: selectedPayloadType,
                            priority: priority,
                            isSandbox: selectedCertificateType == .sandbox)
            try await AppDatabase.shared.saveAPNS(&apns)
        } catch {
            print(error)
        }
    }
}
