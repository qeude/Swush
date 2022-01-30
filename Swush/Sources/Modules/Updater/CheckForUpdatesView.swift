//
//  CheckForUpdatesView.swift
//  Swush
//
//  Created by Quentin Eude on 30/01/2022.
//

import SwiftUI

struct CheckForUpdatesView: View {
    @ObservedObject var viewModel: UpdaterViewModel
    
    var body: some View {
        Button("Check for Updates…", action: viewModel.checkForUpdates)
            .disabled(!viewModel.canCheckForUpdates)
    }
}

struct CheckForUpdatesView_Previews: PreviewProvider {
    static var previews: some View {
        CheckForUpdatesView(viewModel: UpdaterViewModel())
    }
}
