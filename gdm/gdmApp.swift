//
//  gdmApp.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 01.06.2025.
//

import SwiftUI
import VisionKit

@main
struct gdmApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DataStore())
//                .environment(\.locale, Locale(identifier: "en_US"))
        }
    }
}
