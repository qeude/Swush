//
//  SenderView.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import SwiftUI
import SecurityInterface

struct SenderView: View {
    @Environment(\.appDatabase) private var appDatabase
    @ObservedObject var viewModel: SenderViewModel
    
    var body: some View {
        Form {
            Picker("Certificate: ", selection: $viewModel.selectedIdentity) {
                Text("Select a push certificate...").tag(nil as SecIdentity?)
                ForEach(DependencyProvider.secIdentityService.identities ?? [], id:\.self) {
                    Text($0.humanReadable).tag($0 as SecIdentity?)
                }
            }
            if viewModel.selectedIdentity != nil && viewModel.showCertificateTypePicker {
                Picker("Certificate type: ", selection: $viewModel.selectedCertificateType) {
                    ForEach(APNS.CertificateType.allCases, id:\.self) {
                        Text(APNS.CertificateType.from(value: $0))
                    }
                }.pickerStyle(.segmented)
            }
            if viewModel.selectedIdentity != nil {
                TextField("Token: ", text: $viewModel.token, prompt: Text("Enter your push token here..."))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Picker("Topic: ", selection: $viewModel.selectedTopic) {
                    ForEach(viewModel.topics, id:\.self) {
                        Text($0)
                    }
                }
                Picker("Payload type: ", selection: $viewModel.selectedPayloadType) {
                    ForEach(APNS.PayloadType.allCases, id:\.self) {
                        Text(APNS.PayloadType.from(value: $0))
                    }
                }
                Picker("Priority: ", selection: $viewModel.priority) {
                    ForEach(APNS.Priority.allCases, id:\.self) {
                        Text("\($0.rawValue)")
                    }
                }.pickerStyle(.segmented)
                TextEditor(text: $viewModel.payload)
                    .font(.system(.body, design: .monospaced))
                    .formLabel(Text("Payload: "), verticalAlignment: .top)
                TextField("Name: ", text: $viewModel.name, prompt: Text("Enter the name of your saved APNS here..."))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                HStack {
                        Button {
                            Task {
                                try await viewModel.sendPush()
                            }
                        } label: {
                            Text("🚀 Send")
                        }
                        Button {
                            Task {
                                await save()
                            }
                        } label: {
                            Text("💾 Save")
                        }
                    }
            }
        }
        .navigationTitle(viewModel.name)
        .animation(.interactiveSpring(), value: viewModel.selectedIdentity)
        .padding(20)
        .frame(minWidth: 350, minHeight: 350)
    }
    
    private func save() async {
        do {
            var apns = APNS(
                            id: viewModel.id,
                            name: viewModel.name,
                            creationDate: Date(),
                            identityString: viewModel.selectedIdentity!.humanReadable,
                            rawPayload: viewModel.payload,
                            token: viewModel.token,
                            topic: viewModel.selectedTopic,
                            payloadType: viewModel.selectedPayloadType,
                            priority: viewModel.priority,
                            isSandbox: viewModel.selectedCertificateType == .sandbox)
            try await appDatabase.saveAPNS(&apns)
        } catch {
            print(error)
        }
    }
}

struct SenderView_Previews: PreviewProvider {
    static var previews: some View {
        SenderView(viewModel: SenderViewModel(apns: .new))
    }
}
