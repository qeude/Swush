//
//  DeleteApnsView.swift
//  Swush
//
//  Created by Quentin Eude on 06/02/2022.
//

import SwiftUI

struct DeleteApnsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button {
            guard let apns = appState.selectedApns else { return }
            Task {
                appState.showDeleteAlert(for: apns)
            }
        } label: {
            Text("Delete APNs")
        }
        .keyboardShortcut(.delete, modifiers: [.command])
        .disabled(appState.selectedApns == nil)
    }
}

struct DeleteApnsView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteApnsView()
    }
}
