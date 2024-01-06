//
//  MailApp.swift
//  Mail
//
//  Created by Nathan Lee on 30/12/2023.
//

import SwiftUI
import CoreData

@main
struct MailApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase, initial: false) {
            persistenceController.save()
        }
    }
}
