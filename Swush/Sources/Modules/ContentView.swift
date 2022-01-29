//
//  ContentView.swift
//  Swush
//
//  Created by Quentin Eude on 26/01/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ApnsListView()
            SenderView(viewModel: SenderViewModel())
        }.toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
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
