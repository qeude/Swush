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
    
    @State private var selectedIdentity: SecIdentity? = nil
    @State private var apnsToken: String = ""
    @State private var selectedRawCertificateType: String = APNS.CertificateType.p12(certificate: nil).rawValue

    var body: some View {
        Form {
            certificateTypePickerForm
            switch appState.selectedCertificateType {
                case .p12: certificatePickerForm
                case .p8: apnsTokenForm
            }
            if !appState.selectedCertificateType.isEmptyOrNil {
                topicForm
                commonForm
            }
        }
        .onChange(of: selectedIdentity, perform: { newValue in
            appState.selectedCertificateType = .p12(certificate: selectedIdentity)
        })
        .onChange(of: apnsToken, perform: { newValue in
            appState.selectedCertificateType = .p8(token: apnsToken)
        })
        .onChange(of: selectedRawCertificateType, perform: { newValue in
            switch newValue {
                case "p12": appState.selectedCertificateType = .p12(certificate: selectedIdentity)
                case "p8":  appState.selectedCertificateType =  .p8(token: apnsToken)
                default: fatalError()
            }
        })
        .onAppear {
            self.setup()
        }
        .navigationTitle(appState.name)
        .animation(.interactiveSpring(), value: appState.selectedCertificateType)
        .padding(20)
        .frame(minWidth: 350, minHeight: 350)
    }
    
    private var certificatePickerForm: some View {
        VStack {
            Picker("Certificate: ", selection: $selectedIdentity) {
                Text("Select a push certificate...").tag(nil as SecIdentity?)
                ForEach(DependencyProvider.secIdentityService.identities ?? [], id: \.self) {
                    Text($0.humanReadable).tag($0 as SecIdentity?)
                }
            }
            if selectedIdentity != nil, appState.showCertificateTypePicker {
                Picker("Environment: ", selection: $appState.selectedIdentityType) {
                    ForEach(APNS.IdentityType.allCases, id: \.self) {
                        Text(APNS.IdentityType.from(value: $0))
                    }
                }.pickerStyle(.segmented)
            }
        }
    }
    
    private var apnsTokenForm: some View {
        TextField("APNs token: ", text: $apnsToken, prompt: Text("Paste the content of your .p8 file here ..."))
            .textFieldStyle(.roundedBorder)
    }
    
    private var certificateTypePickerForm: some View {
        Picker("Certificate type: ", selection: $selectedRawCertificateType) {
            ForEach(APNS.CertificateType.allRawCases, id: \.self) {
                Text(APNS.CertificateType.placeholder(for: $0))
            }
        }.pickerStyle(.segmented)
    }
    
    private var topicForm: some View {
        Group {
            switch appState.selectedCertificateType {
                case .p12:
                    Picker("Topic: ", selection: $appState.selectedTopic) {
                        ForEach(appState.topics, id: \.self) {
                            Text($0)
                        }
                    }
                case .p8:
                    TextField("Bundle id: ", text: $appState.selectedTopic, prompt: Text("com.qeude.Swush"))
                        .textFieldStyle(.roundedBorder)
            }
        }
    }
    
    private var commonForm: some View {
        VStack {
            TextField("Device push token: ", text: $appState.deviceToken, prompt: Text("Enter your device push token here..."))
                .textFieldStyle(.roundedBorder)
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
                .cornerRadius(8)
                .formLabel(Text("Payload: "), verticalAlignment: .top)
            HStack {
                Button {
                    Task {
                        try await appState.sendPush()
                    }
                } label: {
                    Text("🚀 Send")
                }.keyboardShortcut(.return, modifiers: [.command])
            }
        }
    }
    
    private func setup() {
        switch appState.selectedCertificateType {
            case .p12(let certificate): selectedIdentity = certificate
            case .p8(let token): apnsToken = token
        }
    }
}

struct SenderView_Previews: PreviewProvider {
    static var previews: some View {
        SenderView()
    }
}
