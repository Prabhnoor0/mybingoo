//
//  MyBingoApp.swift
//  MyBingo
//
//  Created by Prabhnoor Kaur on 23/06/25.
//

import SwiftUI
import Firebase
import FirebaseDatabase

@main
struct MyBingoApp: App {
    
    init() {
        print("🚀 App starting...")
        
        // Check for GoogleService-Info.plist
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            print("✅ Found GoogleService-Info.plist at: \(path)")
            FirebaseApp.configure()
            print("✅ Firebase configured successfully")
            
            // Test database connection
            let _ = Database.database().reference()
            print("✅ Firebase Database initialized")
            
        } else {
            print("❌ GoogleService-Info.plist not found!")
            print("📁 Searching in bundle: \(Bundle.main.bundlePath)")
            
            // List all plist files
            let plists = Bundle.main.paths(forResourcesOfType: "plist", inDirectory: nil)
            print("📄 Found plist files: \(plists)")
            
            // Configure anyway for development
            FirebaseApp.configure()
            print("⚠️ Firebase configured without plist")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ModeSelectionView()
        }
    }
}
