//
//  SettingsView.swift
//  Swush
//
//  Created by Quentin Eude on 30/01/2022.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var viewModel: UpdaterViewModel

  private enum Tabs: Hashable {
    case general, advanced
  }

  var body: some View {
    TabView {
      GeneralSettingsView()
        .tabItem {
          Label("General", systemImage: "gear")
        }
        .tag(Tabs.general)
    }
    .padding(20)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}
