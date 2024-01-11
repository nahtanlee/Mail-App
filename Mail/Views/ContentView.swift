//
//  ContentView.swift
//  Mail
//
//  Created by Nathan Lee on 30/12/2023.
//

import SwiftUI
import MailCore
import CoreData
import CoreMotion

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

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var x = 0.0
    @Published var y = 0.0
    @Published var gradientAngle = 0.0
    @Published var angle = Angle(degrees: 0)

    let rollSense: Double = 2.0
    let pitchSense: Double = 2
    
    init() {
        motionManager.deviceMotionUpdateInterval = 1 / 15
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let motion = data?.attitude else { return }
            self?.x = motion.roll
            self?.y = motion.pitch

            // Adjust the gradient angle based on roll and pitch
            let rollAngle = ((1 - motion.roll) * 180 / .pi) * (self?.rollSense ?? 1)
            let pitchAngle = ((1 - motion.pitch) * 180 / .pi) * (self?.pitchSense ?? 1)
            self?.gradientAngle = rollAngle + pitchAngle
            
            guard let motion = data?.attitude else { return }
            let angleInDegrees = atan2(motion.roll, motion.pitch) * 180 / .pi
            self?.angle = Angle(degrees: angleInDegrees)
        }
    }
}


struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject var sessionInfo = SessionInfo()
    @StateObject private var motion = MotionManager()

    
    var body: some View {
        let database = CoreDatabase(context: managedObjectContext)
        let persistenceController = PersistenceController.shared
                
        ZStack {
            CameraView()
                .persistentSystemOverlays(.hidden)
                .ignoresSafeArea(.all)
                .blur(radius: 100)

            if !sessionInfo.loginSetup {
                SetupView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(sessionInfo)
                    .environmentObject(motion)
            } else {
                MenuView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(sessionInfo)
                    .clipped()
            }

        }
    }
}


/*                
 RoundedRectangle(cornerRadius: 25)
 .fill(Color(red: 0.50, green: 0.50, blue: 0.50).opacity(0.30))
 .strokeBorder(AngularGradient(stops: [
     Gradient.Stop(color: .white.opacity(0.2), location: 0),
     Gradient.Stop(color: .white.opacity(0), location: 0.05),
     Gradient.Stop(color: .white.opacity(0), location: 0.30),
     Gradient.Stop(color: .white.opacity(0.5), location: 0.50),
     Gradient.Stop(color: .white.opacity(0), location: 0.70),
     Gradient.Stop(color: .white.opacity(0), location: 0.95),
     Gradient.Stop(color: .white.opacity(0.2), location: 1),
 ], center: UnitPoint(x: 0.5, y: 0.5), angle: motion.angle), lineWidth: 1)
 .clipShape(RoundedRectangle(cornerRadius: 25))
 .padding(.vertical, 1)
 .padding(.horizontal, 10)
 .shadow(radius: 20)
 */
