//
//  MailCoreFunctions.swift
//  Mail
//
//  Created by Nathan Lee on 5/1/2024.
//

import SwiftUI
import CoreData
import MailCore

func checkSession(database: CoreDatabase, completion: @escaping (Bool) -> Void)  {
    //@Environment(\.managedObjectContext) var managedObjectContext
    
    print("Checking session")
    
    let session = MCOIMAPSession()
    session.isVoIPEnabled = false
    
    database.read(entity: "Login", attribute: "email") { email in
        session.username = email
    }
    
    database.read(entity: "Login", attribute: "password") { password in
        session.password = password
    }
    
        
    session.hostname       = "imap.gmail.com"
    session.port           = 993
    session.connectionType = .TLS
    // session.password       = "hrll hurc ikmb xwhl"
    
    
    
    if let op = session.checkAccountOperation() {
        op.start { err in
            if let err = err {
                print("IMAP Connect Error: \(err)")
                completion(false)
            } else {
                print("Successful IMAP connection")
                completion(true)
            }
        }
    } else {

    }
}


func startSession(database: CoreDatabase, completion: @escaping (MCOIMAPSession) -> Void) {
    //@Environment(\.managedObjectContext) var managedObjectContext
    
    
    
    print("session starting")
    
    let session = MCOIMAPSession()
    session.isVoIPEnabled = false
    
    database.read(entity: "Login", attribute: "email") { email in
        session.username = email
    }
    
    database.read(entity: "Login", attribute: "password") { password in
        session.password = password
    }
    
        
    session.hostname       = "imap.gmail.com"
    session.port           = 993
    session.connectionType = .TLS
    // session.password       = "hrll hurc ikmb xwhl"
    
    
    
    if let op = session.checkAccountOperation() {
        op.start { err in
            if let err = err {
                print("IMAP Connect Error: \(err)")
            } else {
                print("Successful IMAP connection")
                completion(session)
            }
        }
    }
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


func searchFolders(session: MCOIMAPSession, completion: @escaping ([MCOIMAPFolder]) -> Void) {
    if let op = session.fetchAllFoldersOperation() {
        op.start { error, folderList in
            
            if let err = error {
                print("Error fetching folders: \(err)")
                return
            }
            
            if let folders = folderList {
                print("Searched \(folders.count) IMAP Folders: \(folders.debugDescription)")
                completion(folders)
            }
        }
    }
}


func sessionReload(sessionInfo: SessionInfo, database: CoreDatabase, completion: @escaping (Bool) -> Void) {
    startSession(database: database) { session in
        sessionInfo.session = session
        searchFolders(session: sessionInfo.session!) { folders in
            sessionInfo.folderList = folders
            searchMessages(session: sessionInfo.session!, since: sessionInfo.date, unreadOnly: false) { updatedMessages in
                sessionInfo.updateMessages(updatedMessages)
                print(sessionInfo.messages.count)
                completion(true)
            }

        }
    }

}
