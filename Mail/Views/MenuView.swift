//
//  MenuView.swift
//  Mail
//
//  Created by Nathan Lee on 2/1/2024.
//

import SwiftUI
import MailCore
struct MenuView: View {
    @EnvironmentObject var sessionInfo: SessionInfo
    @Environment(\.managedObjectContext) var managedObjectContext


    var body: some View {
        let database = CoreDatabase(context: managedObjectContext)
        NavigationStack {
            ZStack {
                
                List {
                    NavigationLink(destination: FolderView().environmentObject(sessionInfo)) {
                        Image(systemName: "tray")
                            .imageScale(.large)
                            .foregroundStyle(.blue)
                        Text("Inbox")
                    }
                    

                }
                .navigationTitle("Mail")
            }
        }
        
        .onAppear {
            sessionInfo.session = startSession(database: database)
            sessionInfo.date = Date(timeIntervalSinceNow: -7 * 24 * 60 * 60)
            searchMessages(session: sessionInfo.session ?? MCOIMAPSession(), since: sessionInfo.date, unreadOnly: false) { updatedMessages in
                sessionInfo.updateMessages(updatedMessages)
                print(sessionInfo.messages.count)
            }
            searchFolders(session: sessionInfo.session ?? MCOIMAPSession())
        }
        
    }
}





#Preview {
    MenuView()
}
