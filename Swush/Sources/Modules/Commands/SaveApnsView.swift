//
//  SaveApnsView.swift
//  Swush
//
//  Created by Quentin Eude on 06/02/2022.
//

import SwiftUI

struct SaveApnsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button {
            Task {
                await appState.save()
            }
        } label: {
            Text("Save APNs")
        }
        .keyboardShortcut("s", modifiers: [.command])
        .disabled(appState.selectedApns == nil)
    }
}

struct SaveApnsView_Previews: PreviewProvider {
    static var previews: some View {
        SaveApnsView()
    }
}
