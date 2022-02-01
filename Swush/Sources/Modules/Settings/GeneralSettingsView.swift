//
//  GeneralSettingsView.swift
//  Swush
//
//  Created by Quentin Eude on 30/01/2022.
//

import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject var viewModel: UpdaterViewModel

    var body: some View {
        Form {
            Toggle("Automatically check for updates", isOn: $viewModel.automaticallyChecksForUpdates)
        }
        .padding(20)
        .frame(width: 375, height: 150)
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
