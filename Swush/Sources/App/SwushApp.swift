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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.appDatabase, .shared)
                .onAppear {
                    if updaterViewModel.canCheckForUpdates {
                        updaterViewModel.checkForUpdates()
                    }
                }
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(viewModel: updaterViewModel)
            }
        }
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
