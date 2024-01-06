//
//  NetworkController.swift
//  Mail
//
//  Created by Nathan Lee on 30/12/2023.
//

import Foundation

struct NetworkController {
    
    private static let baseUrl = "gmail.com"
    
    enum Endpoint {
        case mailMessages(path: String = "/json/email.json")
        
        var url: URL? {
            var components = URLComponents()
            
            components.scheme = "https"
            components.host = baseUrl
            components.path = path
            
            return components.url
        }
        
        private var path: String {
            switch self {
            case .mailMessages(let path):
                return path
            }
        }
    }
    
    static func fetchMailMessages(at endpoint: Endpoint = .mailMessages(), _ completion: @escaping (([Mail.Message]) -> Void)) {
        if let url = endpoint.url {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("An error has occured:", error)
                }
                
                if let data = data {
                    do {
                        let mail = try JSONDecoder().decode(Mail.self, from: data)
                        completion(mail.messages)
                    } catch let error {
                        print ("A decoding error has occured:", error.localizedDescription )
                    }
                }
            }.resume()
        }
    }
    
}
