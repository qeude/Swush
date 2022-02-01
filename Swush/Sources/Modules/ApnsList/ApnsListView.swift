//
//  ApnsList.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import SwiftUI
import GRDBQuery

struct ApnsListView: View {
    @Environment(\.appDatabase) private var appDatabase
    @EnvironmentObject private var appState: AppState
    
    @Query(APNSRequest(ordering: .byName), in: \.appDatabase) private var apnsList: [APNS]
    @State private var searchText: String = ""
    @FocusState private var renameTextFieldIsFocused: Bool

    private var filteredApnsList: [APNS] {
        if searchText.isEmpty {
            return apnsList
        } else {
            return apnsList.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        List {
            ForEach(filteredApnsList) { apns in
                if appState.apnsToRename?.id == apns.id {
                    editView(with: apns)
                } else {
                    readView(with: apns)
                }
            }
        }
        .onChange(of: appState.renameTextFieldIsFocused) {
            renameTextFieldIsFocused = $0
        }
        .onChange(of: renameTextFieldIsFocused) {
            appState.renameTextFieldIsFocused = $0
        }
        .searchable(text: $searchText, placement: .sidebar)
        .listStyle(SidebarListStyle())
    }
    
    private func editView(with apns: APNS) -> some View {
        TextField(apns.name, text: $appState.newName, onEditingChanged: { editingChanged in
            if !editingChanged {
                Task {
                    await appState.performRenaming()
                }
            }
        })
            .focused($renameTextFieldIsFocused)
            .frame(height: 30)
    }
    
    private func readView(with apns: APNS) -> some View {
        NavigationLink(apns.name) {
            SenderView(viewModel: SenderViewModel(apns: apns))
        }
        .frame(height: 30)
        .contextMenu {
            Button {
                appState.startRenaming(apns)
            } label: {
                Text("Rename")
            }
            Button {
                appState.showDeleteAlert(for: apns)
            } label: {
                Text("Delete")
            }
        }
        .alert("Do you really want to delete the APNS named \"\(appState.apnsToDelete?.name ?? "")\"? ", isPresented: $appState.showDeleteAlert) {
            Button("Yes") {
                Task {
                    guard let apnsToDelete = appState.apnsToDelete else { return }
                    await appState.delete(apns: apnsToDelete)
                }
            }
            Button("No") {}
        }
    }
}

struct ApnsListView_Previews: PreviewProvider {
    static var previews: some View {
        ApnsListView()
    }
}
