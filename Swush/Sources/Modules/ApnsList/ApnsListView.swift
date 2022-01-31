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

    @Query(APNSRequest(ordering: .byName), in: \.appDatabase) var apnsList: [APNS]
    @State private var showDeleteAlert: Bool = false
    @State private var apnsToDelete: APNS? = nil
    @State private var searchText: String = ""
    
    var filteredApnsList: [APNS] {
        if searchText.isEmpty {
            return apnsList
        } else {
            return apnsList.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        List {
            ForEach(filteredApnsList) { apns in
                NavigationLink(apns.name) {
                    SenderView(viewModel: SenderViewModel(apns: apns))
                }
                .frame(height: 30)
                .contextMenu {
                    Button {
                        showDeleteAlert(for: apns)
                    } label: {
                        Text("Delete")
                    }
                }
                .alert("Do you really want to delete the APNS named \"\(apnsToDelete?.name ?? "")\"? ", isPresented: $showDeleteAlert) {
                    Button("Yes") {
                        Task {
                            guard let apnsToDelete = apnsToDelete else { return }
                            await delete(apns: apnsToDelete)
                            self.apnsToDelete = nil
                        }
                    }
                    Button("No") {}
                }
            }
        }
        .searchable(text: $searchText, placement: .sidebar)
        .listStyle(SidebarListStyle())
    }
    
    private func showDeleteAlert(for apns: APNS) {
        apnsToDelete = apns
        showDeleteAlert = true
    }
    
    private func delete(apns: APNS) async {
        guard let id = apns.id else { return }
        do {
            try await appDatabase.deleteAPNS(ids: [id])
        } catch {
            print(error)
        }
    }
}

struct ApnsListView_Previews: PreviewProvider {
    static var previews: some View {
        ApnsListView()
    }
}
