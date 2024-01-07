//
//  FolderView.swift
//  Mail
//
//  Created by Nathan Lee on 31/12/2023.
//

import SwiftUI
import MailCore

struct FolderView: View {
    @EnvironmentObject var sessionInfo: SessionInfo
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 7) {
                            if sessionInfo.messages.isEmpty {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(1.5)
                                    .padding()
                            } else {
                                ForEach(sessionInfo.messages, id: \.uid) { message in
                                    NavigationLink {
                                        MessageView(selectedMessage: message)
                                            .environmentObject(sessionInfo)
                                            .toolbarRole(.editor)
                                    } label: {
                                        ZStack {
                                            if !message.flags.contains(.seen) {
                                                RoundedRectangle(cornerRadius: 15)
                                                    .opacity(0.2)
                                                    .tint(.blue)
                                                RoundedRectangle(cornerRadius: 15)
                                                    .foregroundStyle(.thinMaterial)
                                            } else {
                                                RoundedRectangle(cornerRadius: 15)
                                                    .foregroundStyle(.thinMaterial)
                                            }
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
                                                    let plainText = htmlContent // Replace this with your HTML to plain text conversion logic
                                                    let preview = String(plainText)
                                                    Text(preview)
                                                        .lineLimit(2)
                                                        .foregroundStyle(Color(.systemGray2))
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                } else {
                                                    Text("Lorem ipsum dolor sit amet, consectetur adip iscing elit. Pellentesque lobortis eros et eleifend laoreet. Nunc rhoncus accumsan rhoncus.")
                                                        .lineLimit(2)
                                                        .foregroundStyle(Color(.systemGray2))
                                                        .multilineTextAlignment(.leading)
                                                        //.frame(maxWidth: .infinity, alignment: .trailing)
                                                }
                                                    
                                                
                                            }
                                            .padding(11)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                        
                        
                    }
                    .background(UIKitView())
                }
                .navigationBarTitle("Inbox")
            }
            
        }
    }
}


struct UIKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
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






