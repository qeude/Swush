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


    var body: some View {
        List {
            ForEach(apnsList) { apns in
                NavigationLink(apns.name ?? "No name") {
                    SenderView(viewModel: SenderViewModel(apns: apns))
                }
                .frame(height: 35)
                .alert("Do you really want to delete the APNS named \"\(apns.name ?? "")\"? ", isPresented: $showDeleteAlert) {
                    Button("Yes") {
                        Task {
                            await delete(apns: apns)
                        }
                    }
                    Button("No") {}
                }
                .contextMenu {
                    Button {
                        showDeleteAlert(for: apns)
                    } label: {
                        Text("Delete")
                    }
                }
            }
        }
    }
    
    private func showDeleteAlert(for apns: APNS) {
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
