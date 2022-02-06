//
//  SenderView.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import SecurityInterface
import SwiftUI

struct SenderView: View {
    @Environment(\.appDatabase) private var appDatabase
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Form {
            Picker("Certificate: ", selection: $appState.selectedIdentity) {
                Text("Select a push certificate...").tag(nil as SecIdentity?)
                ForEach(DependencyProvider.secIdentityService.identities ?? [], id: \.self) {
                    Text($0.humanReadable).tag($0 as SecIdentity?)
                }
            }
            if appState.selectedIdentity != nil, appState.showCertificateTypePicker {
                Picker("Certificate type: ", selection: $appState.selectedCertificateType) {
                    ForEach(APNS.CertificateType.allCases, id: \.self) {
                        Text(APNS.CertificateType.from(value: $0))
                    }
                }.pickerStyle(.segmented)
            }
            if appState.selectedIdentity != nil {
                TextField("Token: ", text: $appState.token, prompt: Text("Enter your push token here..."))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Picker("Topic: ", selection: $appState.selectedTopic) {
                    ForEach(appState.topics, id: \.self) {
                        Text($0)
                    }
                }
                Picker("Payload type: ", selection: $appState.selectedPayloadType) {
                    ForEach(APNS.PayloadType.allCases, id: \.self) {
                        Text(APNS.PayloadType.from(value: $0))
                    }
                }
                Picker("Priority: ", selection: $appState.priority) {
                    ForEach(APNS.Priority.allCases, id: \.self) {
                        Text("\($0.rawValue)")
                    }
                }.pickerStyle(.segmented)
                TextEditor(text: $appState.payload)
                    .font(.system(.body, design: .monospaced))
                    .formLabel(Text("Payload: "), verticalAlignment: .top)
                HStack {
                    Button {
                        Task {
                            try await appState.sendPush()
                        }
                    } label: {
                        Text("🚀 Send")
                    }
                }
            }
        }
        .navigationTitle(appState.name)
        .animation(.interactiveSpring(), value: appState.selectedIdentity)
        .padding(20)
        .frame(minWidth: 350, minHeight: 350)
    }
}

struct SenderView_Previews: PreviewProvider {
    static var previews: some View {
        SenderView()
    }
}
