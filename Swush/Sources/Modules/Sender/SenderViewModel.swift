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
    @Published var selectedCertificateType: APNS.CertificateType = .sandbox
    @Published var token = ""
    @Published var payload = "{\n\t\"aps\": {\n\t\t\"alert\": \"Push test!\",\n\t\t\"sound\": \"default\",\n\t}\n}"
    @Published var topics: [String] = []
    @Published var priority: APNS.Priority = .high
    @Published var selectedTopic: String = ""
    @Published var showCertificateTypePicker: Bool = false
    @Published var showCompleteForm: Bool = false
    @Published var selectedPayloadType: APNS.PayloadType = .alert
    
    init() {
        if let _ = SFChooseIdentityPanel.shared().identity() {
            showCompleteForm = true
        }
    }
    
    func didChooseIdentity() {
        guard let selectedIdentity = selectedIdentity else {
            showCompleteForm = false
            return
        }
        showCompleteForm = true
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
        guard let payload = payload.toJSON(), let identity = selectedIdentity else { return }
        let apns = APNS(identity: identity, payload: payload, token: token, topic: selectedTopic, payloadType: selectedPayloadType, priority: priority, isSandbox: selectedCertificateType == .sandbox)
        try await DependencyProvider.apnsService.sendPush(for: apns)
    }
}
