//
//  SwushViewModel.swift
//  Swush
//
//  Created by Quentin Eude on 26/01/2022.
//

import SwiftUI
import SecurityInterface

class SwushViewModel: ObservableObject {
    var certificateTypes = ["Sandbox", "Production",]
    @Published  var selectedCertificate = "Sandbox"
    @Published var token = ""
    @Published var payload = ""
    @Published var topics: [String] = []
    @Published var selectedTopic: String = ""
    @Published var showCertificateTypePicker: Bool = false
    @Published var showCompleteForm: Bool = false
    @Published var selectedPayloadType: PayloadType = .alert
    
    init() {
        if let _ = SFChooseIdentityPanel.shared().identity() {
            showCompleteForm = true
        }
    }
    
    @objc func chooseIdentityPanelDidEnd(sheet: NSWindow, returnCode: NSInteger, contextInfo: () -> ()) {
        if returnCode == NSApplication.ModalResponse.OK.rawValue {
            guard let identity = SFChooseIdentityPanel.shared().identity() else {
                showCompleteForm = false
                return
            }
            APNSService.shared.set(identity: identity.takeUnretainedValue())
            showCompleteForm = true
            let type = SecIdentityHelper.apnsSecIdentiyGetType(for: identity.takeRetainedValue())
            showCertificateTypePicker = type == SecIdentityHelper.SecIdentityType.universal

            topics = SecIdentityHelper.apnsSecIdentityGetTopics(for: identity.takeRetainedValue())
            selectedTopic = topics.first ?? ""
        }
    }
}
