//
//  ContentView.swift
//  Swush
//
//  Created by Quentin Eude on 26/01/2022.
//

import SwiftUI
import SecurityInterface

extension String {
    func toJSON() -> [String: Any]? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
    }
}
struct ContentView: View {
    @ObservedObject var viewModel = SwushViewModel()
    
    var body: some View {
        Form {
            HStack {
                Button {
                    certificatePanel()
                } label: {
                    Text("Choose")
                }.formLabel(Text("Certificate: "))
                if viewModel.showCompleteForm && viewModel.showCertificateTypePicker {
                    Picker(selection: $viewModel.selectedCertificate) {
                        ForEach(viewModel.certificateTypes, id:\.self) {
                            Text($0)
                        }
                    } label: {}.pickerStyle(.segmented)

                }
            }
            if viewModel.showCompleteForm {
                TextField("Token: ", text: $viewModel.token, prompt: Text("Enter your push token here..."))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Picker("Topic: ", selection: $viewModel.selectedTopic) {
                    ForEach(viewModel.topics, id:\.self) {
                        Text($0)
                    }
                }
                Picker("Payload type: ", selection: $viewModel.selectedPayloadType) {
                    ForEach(PayloadType.allCases, id:\.self) {
                        Text(PayloadType.from(value: $0))
                    }
                }
                TextEditor(text: $viewModel.payload)
                    .font(.system(.body, design: .monospaced))
                    .formLabel(Text("Payload: "), verticalAlignment: .top)
                Button {
                    print("Send push")
                    Task {
                        try await sendPush()
                    }
                } label: {
                    Text("Send 🚀")
                }
            }
        }
        .animation(.interactiveSpring(), value: viewModel.showCompleteForm)
        .padding(20)
        .frame(minWidth: 350, minHeight: 350)
    }
    private func sendPush() async throws {
        guard let payload = viewModel.payload.toJSON() else { return }
        let apns = APNS(payload: payload, token: viewModel.token, topic: viewModel.selectedTopic, payloadType: viewModel.selectedPayloadType, priority: 10, isSandbox: viewModel.selectedCertificate == "Sandbox")
        try await APNSService.shared.sendPush(for: apns)
    }

    private func certificatePanel() {
        let panel = SFChooseIdentityPanel.shared()
        panel?.setAlternateButtonTitle("Cancel")
        panel?.beginSheet(for: NSApplication.shared.keyWindow!, modalDelegate: viewModel , didEnd: #selector(viewModel.chooseIdentityPanelDidEnd), contextInfo: nil, identities: SecIdentityHelper.identities, message: "Choose the identity to use for delivering notifications")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
