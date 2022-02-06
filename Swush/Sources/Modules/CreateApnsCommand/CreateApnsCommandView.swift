//
//  CreateApnsCommandView.swift
//  Swush
//
//  Created by Quentin Eude on 31/01/2022.
//

import SwiftUI

struct CreateApnsCommandView: View {
  @Environment(\.appDatabase) private var appDatabase
  @EnvironmentObject var appState: AppState

  var body: some View {
    Button {
      Task {
        await appState.create()
      }
    } label: {
      Text("New APNS")
    }
    .keyboardShortcut("n", modifiers: [.command])
    .disabled(!appState.canCreateNewApns)
  }

  private func create() async {
    do {
      var apns = APNS.new
      try await appDatabase.saveAPNS(&apns)
    } catch {
      print(error)
    }
  }
}

struct CreateApnsCommandView_Previews: PreviewProvider {
  static var previews: some View {
    CreateApnsCommandView()
  }
}
