//
//  MenuView.swift
//  Mail
//
//  Created by Nathan Lee on 2/1/2024.
//

import SwiftUI
import MailCore

let FolderIcons: [String: String] = [
    "Inbox" : "tray"
]

struct MenuView: View {
    @EnvironmentObject var sessionInfo: SessionInfo
    @Environment(\.managedObjectContext) var managedObjectContext


    var body: some View {
        let database = CoreDatabase(context: managedObjectContext)
            VStack {
                Text("Mail")
                    .font(.largeTitle)
                
                LazyVStack {
                    ForEach(sessionInfo.folderList, id: \.path) { folder in
                        Button(action: {
                            print("Folder pressed: \(folder.path)")
                        }, label: {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundStyle(Color.white.opacity(0))
                            Text("\(folder.path)")
                        })
                        
                    }

                }
                .padding(11)
            }
            .padding(.horizontal, 15)
        
    }
}





#Preview {
    MenuView()
}
