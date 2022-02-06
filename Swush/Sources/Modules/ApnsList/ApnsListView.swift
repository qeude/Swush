//
//  ApnsList.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import GRDBQuery
import SwiftUI

struct ApnsListView: View {
  @Environment(\.appDatabase) private var appDatabase
  @EnvironmentObject private var appState: AppState

  @Query(APNSRequest(ordering: .byName), in: \.appDatabase) private var apnsList: [APNS]
  @State private var searchText: String = ""

  @FocusState private var isFocused: Bool

  private var filteredApnsList: [APNS] {
    if searchText.isEmpty {
      return apnsList
    } else {
      return apnsList.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
  }

  var body: some View {
    List(filteredApnsList) { apns in
      NavigationLink(
        destination: SenderView(),
        isActive: appState.selectionBindingForId(apns: apns)
      ) {
        if appState.apnsToRename?.id == apns.id {
          TextField(
            apns.name,
            text: $appState.newName,
            onEditingChanged: { editingChanged in
              if !editingChanged {
                Task {
                  await appState.performRenaming()
                }
              }
            }
          )
          .onDisappear {
            isFocused = false
          }
          .onAppear {
            isFocused = true
          }
          .focused($isFocused)
        } else {
          Text(apns.name)
        }
      }
      .frame(height: 30)
      .contextMenu {
        Button {
          appState.startRenaming(apns)
        } label: {
          Text("Rename")
        }
        .disabled(!appState.canRenameApns)
        Button {
          appState.showDeleteAlert(for: apns)
        } label: {
          Text("Delete")
        }
      }
      .alert(
        "Do you really want to delete the APNS named \"\(appState.apnsToDelete?.name ?? "")\"? ",
        isPresented: $appState.showDeleteAlert
      ) {
        Button("Yes") {
          Task {
            guard let apnsToDelete = appState.apnsToDelete else { return }
            await appState.delete(apns: apnsToDelete)
          }
        }
        Button("No") {}
      }
    }
    .searchable(text: $searchText, placement: .sidebar)
    .listStyle(SidebarListStyle())
  }
}

struct ApnsListView_Previews: PreviewProvider {
  static var previews: some View {
    ApnsListView()
  }
}
