//
//  MessageView.swift
//  Mail
//
//  Created by Nathan Lee on 2/1/2024.
//

import SwiftUI
import MailCore

struct MessageView: View {
    @EnvironmentObject var sessionInfo: SessionInfo
    var selectedMessage: MCOIMAPMessage
    //let message = sessionInfo.selectedMessage
    
    var body: some View {
        let message = selectedMessage
           ScrollView {
               VStack(alignment: .leading, spacing: 10) {
                   Text("From: \(message.header.from?.displayName ?? "")")
                   Text("Date: \(formatDate(message.header.date))")
                   Text("Subject: \(message.header.subject ?? "")")

                   if let body = message.htmlRendering(withFolder: "INBOX", delegate: nil) {
                                Text("Body: \(body)")
                                           .lineLimit(nil) // Allow multiple lines for the body
                                           .fixedSize(horizontal: false, vertical: true) // Allow multiline text to expand vertically
                                   } else {
                                       Text("Body: nil")
                                           .lineLimit(nil)
                                           .fixedSize(horizontal: false, vertical: true)
                                   }
               }
               .padding()
           }
           .background(Color.clear)
        
       }
    

       private func formatDate(_ date: Date?) -> String {
           guard let date = date else { return "" }

           let formatter = DateFormatter()
           formatter.dateStyle = .medium
           formatter.timeStyle = .medium

           return formatter.string(from: date)
       }
}
