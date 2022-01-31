//
//  CreateApnsCommandView.swift
//  Swush
//
//  Created by Quentin Eude on 31/01/2022.
//

import SwiftUI

struct CreateApnsCommandView: View {
    @Environment(\.appDatabase) private var appDatabase

    var body: some View {
        Button {
            Task {
                await create()
            }
        } label: {
            Text("New APNS")
        }.keyboardShortcut("n", modifiers: [.command])
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
