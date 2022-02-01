//
//  ContentView.swift
//  Swush
//
//  Created by Quentin Eude on 26/01/2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.appDatabase) private var appDatabase
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ApnsListView()
            Text("Create your first APNS to start using the app. 🚀")
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
            ToolbarItem(placement: .navigation) {
                Button {
                    Task {
                        await appState.create()
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
