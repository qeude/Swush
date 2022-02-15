//
//  SenderView.swift
//  Swush
//
//  Created by Quentin Eude on 29/01/2022.
//

import SecurityInterface
import SwiftUI
import Foundation
import UniformTypeIdentifiers

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
            VStack(alignment: .leading, spacing: 38) {
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
            .alert(Text("An error occured!"), isPresented: $appState.showErrorMessage, actions: {}, message: {
                Text(appState.errorMessage)
            })
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
        Input(label: "Certificate", help: "Certificates are retrieved from your Keychain. \n⚠️ If nothing appears here, it means that you have no APNs certificate stored in your keychain.\n\nYou need to retrieve it from [Certificates, Identifiers & Profiles → Certificates](https://developer.apple.com/account/resources/certificates/list) and add it to your Keychain by double-clicking on it.") {
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
            Input(label: "Key file", help: "The `.p8` file corresponding to your key. \n\nAvailable at [Certificates, Identifiers & Profiles → Keys](https://developer.apple.com/account/resources/authkeys/list).") {
                HStack {
                    Button {
                        let filePath = showOpenPanel()
                        self.apnsTokenFilename = filePath?.path ?? ""
                    } label: {
                        Text("Select .p8 file")
                    }
                    Text(self.apnsTokenFilename.split(separator: "/").last ?? "")
                }
            }
            Input(label: "Team id", help: "The Team ID of your Apple Developer Account. \n\nAvailable at [Membership](https://developer.apple.com/account/#!/membership/).") {
                TextField(text: $teamId, prompt: Text("Paste your team id here ..."), label: {})
                    .textFieldStyle(.roundedBorder)
            }
            Input(label: "Key id", help: "The key id associated to the selected `.p8` file. \n\nAvailable at [Certificates, Identifiers & Profiles → Keys](https://developer.apple.com/account/resources/authkeys/list).") {
                TextField(text: $keyId, prompt: Text("Paste your key id here ..."), label: {})
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
    
    private func showOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [UTType(filenameExtension: "p8")!]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
    
    private var configForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configuration").font(.title).bold()
            Input(label: "Device push token", help: "The device token for the user's device. \nYour app receives this device token when registering for remote notifications.") {
                TextField(text: $appState.deviceToken, prompt: Text("Enter your device push token here..."), label: {})
                    .textFieldStyle(.roundedBorder)
            }
            if appState.showCertificateTypePicker {
                Input(label: "Environment", help: "APNs server to use to send your notification. \n- **sandbox**: for apps signed with iOS Development Certificate, mostly apps in debug mode. \n- **production**: for apps signed with iOS Distribution Certificate, mostly apps in release mode.") {
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
            Input(label: "Push type", help: "The value of this header must accurately reflect the contents of your notification's payload. \nThe apns-push-type header field has six valid values: \n- **alert**: Use the alert push type for notifications that trigger a user interaction--for example, an alert, badge, or sound \n- **background**: Use the background push type for notifications that deliver content in the background, and don't trigger any user interactions. \n- **voip**: Use the voip push type for notifications that provide information about an incoming Voice-over-IP (VolP) call. \n- **complication**: Use the complication push type for notifications that contain update information for a watchOS app's complications \n- **fileprovider**: Use the fileprovider push type to signal changes to a File Provider extension \n- **mdm**: Use the mdm push type for notifications that tell managed devices to contact the MDM server") {
                Picker(
                    selection: $appState.selectedPayloadType,
                    content: {
                        ForEach(APNS.PayloadType.allCases, id: \.self) {
                            Text(APNS.PayloadType.from(value: $0))
                        }
                    },
                    label: {})
            }
            Input(label: "Priority", help: "The priority of the notification.\n- Specify 10 to send the notification immediately.\n- Specify 5 to send the notification based on power considerations on the user's device.\n\nFor background notifications, using \"⚡️Immediately\" is an error.") {
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
        Input(label: "Bundle id", help: "The topic for the notification. \nMost of the time, the topic is your app's bundle ID/app ID. It can have a suffix based on the type of push notification. \nIf you are using a certificate that supports Pushkit VolP or watchOS complication notifications, you must include this header with bundle ID of you app and if applicable, the proper suffix. \nIf you are using token-based authentication with APNs, you must include this header with the correct bundle ID and suffix combination") {
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
