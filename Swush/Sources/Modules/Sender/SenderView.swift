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
    @State private var apnsTokenFilename: String = ""
    @State private var teamId: String = ""
    @State private var keyId: String = ""
    @State private var selectedRawCertificateType: String = APNS.CertificateType.p12(certificate: nil).rawValue

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                authenticationForm
                if !appState.selectedCertificateType.isEmptyOrNil {
                    configForm
                    payloadForm
                }
            }
            .onChange(of: selectedIdentity, perform: { newValue in
                appState.selectedCertificateType = .p12(certificate: selectedIdentity)
            })
            .onChange(of: apnsTokenFilename, perform: { newValue in
                appState.selectedCertificateType = .p8(tokenFilename: apnsTokenFilename, teamId: teamId, keyId: keyId)
            })
            .onChange(of: teamId, perform: { newValue in
                appState.selectedCertificateType = .p8(tokenFilename: apnsTokenFilename, teamId: teamId, keyId: keyId)
            })
            .onChange(of: keyId, perform: { newValue in
                appState.selectedCertificateType = .p8(tokenFilename: apnsTokenFilename, teamId: teamId, keyId: keyId)
            })
            .onChange(of: selectedRawCertificateType, perform: { newValue in
                switch newValue {
                case "p12": appState.selectedCertificateType = .p12(certificate: selectedIdentity)
                case "p8":  appState.selectedCertificateType =  .p8(tokenFilename: apnsTokenFilename, teamId: teamId, keyId: keyId)
                default: fatalError()
                }
            })
            .onAppear {
                self.setup()
            }
            .navigationTitle(appState.name)
            .animation(.default, value: appState.selectedCertificateType)
            .padding(20)
        }
        .frame(minWidth: 350, minHeight: 350)
    }
    
    private var authenticationForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Authentication").font(.title).bold()
            Picker(
                selection: $selectedRawCertificateType,
                content: {
                    ForEach(APNS.CertificateType.allRawCases, id: \.self) {
                        Text(APNS.CertificateType.placeholder(for: $0))
                    }
                },
                label: {})
                .pickerStyle(.segmented)
                .fixedSize()
            switch appState.selectedCertificateType {
                case .p12: certificateAuthenticationForm
                case .p8: keyAuthenticationForm
            }
        }
    }
    
    private var certificateAuthenticationForm: some View {
        Input(label: "Certificate") {
            Picker(selection: $selectedIdentity, content: {
                Text("Select a push certificate...").tag(nil as SecIdentity?)
                ForEach(DependencyProvider.secIdentityService.identities ?? [], id: \.self) {
                    Text($0.humanReadable).tag($0 as SecIdentity?)
                }
            }, label: {})
        }
    }
    
    private var keyAuthenticationForm: some View {
        Group {
            Input(label: "Key filename") {
                TextField(text: $apnsTokenFilename, prompt: Text("Paste the path to your .p8 file here ..."), label: {})
                    .textFieldStyle(.roundedBorder)
            }
            Input(label: "Team id") {
                TextField(text: $teamId, prompt: Text("Paste your team id here ..."), label: {})
                    .textFieldStyle(.roundedBorder)
            }
            Input(label: "Key id") {
                TextField(text: $keyId, prompt: Text("Paste your key id here ..."), label: {})
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
    
    private var configForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configuration").font(.title).bold()
            Input(label: "Device push token") {
                TextField(text: $appState.deviceToken, prompt: Text("Enter your device push token here..."), label: {})
                    .textFieldStyle(.roundedBorder)
            }
            if appState.showCertificateTypePicker {
                Input(label: "Environment") {
                    Picker(
                        selection: $appState.selectedIdentityType,
                        content: {
                            ForEach(APNS.IdentityType.allCases, id: \.self) {
                                Text(APNS.IdentityType.from(value: $0))
                            }
                        },
                        label: {})
                        .pickerStyle(.segmented)
                        .fixedSize()
                }
            }
            Input(label: "Push type") {
                Picker(
                    selection: $appState.selectedPayloadType,
                    content: {
                        ForEach(APNS.PayloadType.allCases, id: \.self) {
                            Text(APNS.PayloadType.from(value: $0))
                        }
                    },
                    label: {})
            }
            Input(label: "Priority") {
                Picker(
                    selection: $appState.priority,
                    content: {
                        ForEach(APNS.Priority.allCases, id: \.self) {
                            Text($0.placeholder)
                        }
                    },
                    label: {})
                    .pickerStyle(.segmented)
                    .fixedSize()
            }
            topicForm
        }
        .animation(.default, value: appState.showCertificateTypePicker)
    }
    
    private var topicForm: some View {
        Input(label: "Bundle id") {
            switch appState.selectedCertificateType {
            case .p12:
                Picker(selection: $appState.selectedTopic, content: {
                    ForEach(appState.topics, id: \.self) {
                        Text($0)
                    }
                }, label: {})
            case .p8:
                TextField(text: $appState.selectedTopic, prompt: Text("com.qeude.Swush"), label: {})
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
    
    private var payloadForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payload").font(.title).bold()
            TextEditor(text: $appState.payload)
                .font(.system(.body, design: .monospaced))
                .fixedSize(horizontal: false, vertical: true)
                .cornerRadius(8)
        }
    }
    
    private func setup() {
        selectedRawCertificateType = appState.selectedCertificateType.rawValue
        switch appState.selectedCertificateType {
        case .p12(let certificate):
            selectedIdentity = certificate
        case .p8(let tokenFilename, let teamId, let keyId):
            self.apnsTokenFilename = tokenFilename
            self.teamId = teamId
            self.keyId = keyId
        }
    }
}

struct SenderView_Previews: PreviewProvider {
    static var previews: some View {
        SenderView()
    }
}
