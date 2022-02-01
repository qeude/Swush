//
//  UpdaterViewModel.swift
//  Swush
//
//  Created by Quentin Eude on 30/01/2022.
//

import Foundation
import Sparkle

final class UpdaterViewModel: ObservableObject {
    private let updaterController: SPUStandardUpdaterController
    private let delegateHandler = SparkleDelegateHandler()
    
    @Published var canCheckForUpdates = false
    @Published(key: "automaticallyChecksForUpdates") var automaticallyChecksForUpdates = false {
        didSet {
            updaterController.updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates
        }
    }
    
    init() {
        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
        // This is where you can also pass an updater delegate if you need one
        updaterController = SPUStandardUpdaterController(updaterDelegate: delegateHandler, userDriverDelegate: delegateHandler)

        updaterController.updater.updateCheckInterval = TimeInterval(1)
        updaterController.updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates

        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
    
    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
    
    func checkForUpdatesInBackground() {
        if automaticallyChecksForUpdates {
            updaterController.updater.checkForUpdatesInBackground()
        }
    }
    
    private class SparkleDelegateHandler: NSObject, SPUUpdaterDelegate, SPUStandardUserDriverDelegate {
            func feedURLString(for updater: SPUUpdater) -> String? {
                "https://swush.s3.eu-west-2.amazonaws.com/appcast.xml" // or whatever you use
            }
            
        
        }
}
