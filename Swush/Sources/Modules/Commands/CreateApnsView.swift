//
//  CreateApnsCommandView.swift
//  Swush
//
//  Created by Quentin Eude on 31/01/2022.
//

import SwiftUI

struct CreateApnsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button {
            Task {
                await appState.create()
            }
        } label: {
            Text("New APNs")
        }
        .keyboardShortcut("n", modifiers: [.command])
        .disabled(!appState.canCreateNewApns)
    }
}

struct CreateApnsView_Previews: PreviewProvider {
    static var previews: some View {
        CreateApnsView()
    }
}
