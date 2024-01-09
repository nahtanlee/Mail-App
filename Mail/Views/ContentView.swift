//
//  ContentView.swift
//  Mail
//
//  Created by Nathan Lee on 30/12/2023.
//

import SwiftUI
import MailCore
import CoreData


class SessionInfo: ObservableObject {
    
    @Published var session: MCOIMAPSession? = nil
    @Published var date = Date(timeIntervalSinceNow: -7 * 24 * 60 * 60)
    @Published var messages: [MCOIMAPMessage] = []
    @Published var selectedMessage: MCOIMAPMessage = MCOIMAPMessage()
    @Published var folderList: [MCOIMAPFolder] = []
    
    // Core Data
    @Published var loginSetup: Bool = false
    
    
    func updateMessages(_ newMessages: [MCOIMAPMessage]) {
        objectWillChange.send()  // Notify SwiftUI about changes
        messages = newMessages
    }
}



struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject var sessionInfo = SessionInfo()
    
    var body: some View {
        let database = CoreDatabase(context: managedObjectContext)
        let persistenceController = PersistenceController.shared
                
        ZStack {
            CameraView()
                .blur(radius: 70)
                .overlay {
                    Rectangle()
                        .ignoresSafeArea(.all)
                        .foregroundStyle(Color.white.opacity(0.3))
                }
                .onAppear() {
                    database.read(entity: "Login", attribute: "setup") { (setup: Bool?) in
                        sessionInfo.loginSetup = setup ?? false
                        print("\(sessionInfo.loginSetup)")
                    }
                }
            
            
            if !sessionInfo.loginSetup {
                SetupView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(sessionInfo)
            } else {
                MenuView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(sessionInfo)
                    .opacity(1)
            }
            
        }
    }
}
