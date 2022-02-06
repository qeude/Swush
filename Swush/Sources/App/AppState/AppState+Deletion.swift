//
//  AppState+Deletion.swift
//  Swush
//
//  Created by Quentin Eude on 06/02/2022.
//

import Foundation

extension AppState {
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
}
