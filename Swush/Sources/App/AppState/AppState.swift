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
  //MARK: Sidebar
  @Published var showDeleteAlert: Bool = false
  @Published var apnsToDelete: APNS? = nil

  @Published var apnsToRename: APNS? = nil
  @Published var newName: String = ""

  @Published var canCreateNewApns: Bool = true
  @Published var canRenameApns: Bool = true

  @Published var selectedApns: APNS? = nil {
    didSet {
      if let apns = selectedApns, oldValue != selectedApns {
        setApns(apns)
      }
    }
  }

  //MARK: APNS form
  @Published var selectedIdentity: SecIdentity? = nil {
    didSet {
      if oldValue != selectedIdentity {
        didChooseIdentity()
      }
    }
  }
  @Published var name: String = ""
  @Published var selectedCertificateType: APNS.CertificateType = .sandbox
  @Published var token = ""
  @Published var payload =
    "{\n\t\"aps\": {\n\t\t\"alert\": \"Push test!\",\n\t\t\"sound\": \"default\",\n\t}\n}"
  @Published var topics: [String] = []
  @Published var priority: APNS.Priority = .high
  @Published var selectedTopic: String = ""
  @Published var showCertificateTypePicker: Bool = false
  @Published var selectedPayloadType: APNS.PayloadType = .alert

  private func setApns(_ apns: APNS) {
    selectedIdentity = apns.identity
    selectedCertificateType = apns.isSandbox ? .sandbox : .production
    token = apns.token
    payload = apns.rawPayload
    topics = apns.identity?.topics ?? []
    priority = apns.priority
    selectedTopic = apns.topic
    selectedPayloadType = apns.payloadType
    name = apns.name
    didChooseIdentity()
  }

  private func didChooseIdentity() {
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

  func selectionBindingForId(apns: APNS?) -> Binding<Bool> {
    Binding<Bool> { () -> Bool in
      self.selectedApns?.id == apns?.id
    } set: { (newValue) in
      if newValue {
        self.selectedApns = apns
      }
    }
  }
}
