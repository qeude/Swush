//
//  CheckForUpdatesView.swift
//  Swush
//
//  Created by Quentin Eude on 30/01/2022.
//

import SwiftUI

struct CheckForUpdatesView: View {
  @EnvironmentObject var updaterViewModel: UpdaterViewModel

  var body: some View {
    Button("Check for Updates…", action: updaterViewModel.checkForUpdates)
      .disabled(!updaterViewModel.canCheckForUpdates)
  }
}

struct CheckForUpdatesView_Previews: PreviewProvider {
  static var previews: some View {
    CheckForUpdatesView()
  }
}
