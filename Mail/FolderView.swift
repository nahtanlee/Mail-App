//
//  MessageListView.swift
//  Mail
//
//  Created by Nathan Lee on 31/12/2023.
//

import SwiftUI
import MailCore

struct MessageListView: View {
    @EnvironmentObject var sessionInfo: SessionInfo

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 2) {
                        if sessionInfo.messages.isEmpty {
                            Spacer()
                            Text("Loading...")
                                .font(.system(size: 25))
                        } else {
                            ForEach(sessionInfo.messages, id: \.uid) { message in
                                Button(action: {
                                    // Handle button tap for the specific message
                                    print("Button tapped for message with subject: \(message.header.subject ?? "")")
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 25)
                                            .foregroundStyle(.thinMaterial)
                                        // Contents
                                        VStack {
                                            HStack {
                                                Text("\(message.header.from?.displayName ?? "No Sender")")
                                                    .font(.headline)
                                                    .lineLimit(1)
                                                    .foregroundStyle(Color.primary)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                Spacer()
                                                let messageDate = message.header?.date
                                                Text(formattedDate(for: messageDate ?? Date()))
                                                    .lineLimit(1)
                                                    .foregroundStyle(Color(.systemGray2))
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                            }
                                            Text(message.header.subject ?? "No Subject")
                                                .font(.subheadline)
                                                .lineLimit(1)
                                                .foregroundStyle(Color.primary)
                                                .frame(maxWidth: .infinity, alignment: .leading)


                                            // Assuming message is an instance of MCOIMAPMessage
                                            if let htmlContent = message.htmlRendering(withFolder: "INBOX", delegate: nil) {
                                                // Extract plain text from HTML content (you may want to use a library like SwiftSoup for more sophisticated HTML parsing)
                                                let plainText = htmlContent // Replace this with your HTML to plain text conversion logic
                                                let preview = String(plainText)
                                                Text(preview)
                                                    .lineLimit(2)
                                                    .foregroundStyle(Color(.systemGray2))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            } else {
                                                Text("No preview available\n")
                                                    .lineLimit(2)
                                                    .foregroundStyle(Color(.systemGray2))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                                
                                            
                                        }
                                        .padding(10)
                                    }
                                }
                                .padding(.bottom, 9)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    
                }
            }
            .navigationBarTitle("Inbox")
        }
    }
}


func startSession() -> MCOIMAPSession {
    print("start session")
    
    let session = MCOIMAPSession()
    session.isVoIPEnabled = false
        
    session.hostname       = "imap.gmail.com"
    session.port           = 993
    session.connectionType = .TLS
    session.username       = "nahtanlee@gmail.com"
    session.password       = "hrll hurc ikmb xwhl"
    
    if let op = session.checkAccountOperation() {
        op.start { err in
            if let err = err {
                print("IMAP Connect Error: \(err)")
            } else {
                print("Successful IMAP connection")
            }
        }
    }
    return session
}




func searchMessages(session: MCOIMAPSession, since: Date, unreadOnly: Bool, completion: @escaping ([MCOIMAPMessage]) -> Void) {
    var search = MCOIMAPSearchExpression.search(sinceReceivedDate: since)
    
    if unreadOnly {
        search = MCOIMAPSearchExpression.searchAnd(search, other: MCOIMAPSearchExpression.searchUnread())
    }

    if let op = session.searchExpressionOperation(withFolder: "INBOX", expression: search) {
        op.start { error, messageIds in
            if let err = error {
                print("Error searching IMAP: \(err)")
                return
            }
      
            if let messageIds = messageIds {
                if let messageOp = session.fetchMessagesOperation(withFolder: "INBOX", requestKind: [ .flags, .fullHeaders, .internalDate, .size, .structure], uids: messageIds) {
          
                    // if you would like to fetch some non-standard headers
                    messageOp.extraHeaders = [ "Delivered-To" ]

                    messageOp.start { error, messages, _ in
                        if let error = error {
                            print("Error fetching messages: \(error)")
                            return
                        }

                        if let messages = messages {
                            print("Retrieved \(messages.count) message(s) from IMAP server:")
                            print("Messages: \(messages.debugDescription)")
                            completion(messages.reversed())
                        }
                    }
                }
            }
        }
    }
}



// Format the date string relative to today
extension DateFormatter {
    static let emailDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()
}

func formattedDate(for date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()

    if calendar.isDateInToday(date) {
        // Show time if the email was received today
        DateFormatter.emailDateFormatter.dateFormat = "h:mm a"
        return DateFormatter.emailDateFormatter.string(from: date)
    } else if let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now),
              date >= sevenDaysAgo {
        // Show day of the week if the email was received in the past 7 days (but not today)
        DateFormatter.emailDateFormatter.dateFormat = "EEEE"
        return DateFormatter.emailDateFormatter.string(from: date)
    } else {
        // Show date in the format DD/MM/YYYY if it was received over a week ago
        DateFormatter.emailDateFormatter.dateFormat = "dd/MM/yyyy"
        return DateFormatter.emailDateFormatter.string(from: date)
    }
}






/*
#Preview {
    MessageListView()
}
*/
