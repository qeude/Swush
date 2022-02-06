//
//  AppState+Send.swift
//  Swush
//
//  Created by Quentin Eude on 06/02/2022.
//

import Foundation

extension AppState {
  func sendPush() async throws {
    guard let _ = payload.toJSON(), let identity = selectedIdentity else { return }
    let apns = APNS(
      name: name, creationDate: selectedApns?.creationDate ?? Date(),
      updateDate: selectedApns?.updateDate ?? Date(),
      identityString: identity.humanReadable, rawPayload: payload, token: token,
      topic: selectedTopic, payloadType: selectedPayloadType, priority: priority,
      isSandbox: selectedCertificateType == .sandbox)
    try await DependencyProvider.apnsService.sendPush(for: apns)
  }
}
