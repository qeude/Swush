//
//  SwushApp.swift
//  Swush
//
//  Created by Quentin Eude on 26/01/2022.
//

import SwiftUI

@main
struct SwushApp: App {
  @StateObject var updaterViewModel = UpdaterViewModel()
  @StateObject var appState = AppState()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(appState)
        .environment(\.appDatabase, .shared)
        .onAppear {
          updaterViewModel.checkForUpdatesInBackground()
        }
        .environmentObject(updaterViewModel)
    }
    .commands {
      CommandGroup(after: .appInfo) {
        CheckForUpdatesView()
          .environmentObject(updaterViewModel)
      }
      CommandGroup(replacing: .newItem) {
        CreateApnsCommandView()
          .environmentObject(appState)
      }
    }

    #if os(macOS)
      Settings {
        SettingsView().environmentObject(updaterViewModel)
      }
    #endif
  }
}

private struct AppDatabaseKey: EnvironmentKey {
  static var defaultValue: AppDatabase { .empty() }
}

extension EnvironmentValues {
  var appDatabase: AppDatabase {
    get { self[AppDatabaseKey.self] }
    set { self[AppDatabaseKey.self] = newValue }
  }
}
