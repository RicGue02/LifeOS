//
//  SettingsView.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @State private var showingAbout = false
    @State private var showingPrivacy = false
    @State private var showingNotificationAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                // User Section
                Section {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading) {
                            Text("User")
                                .font(.headline)
                            Text("Productivity Enthusiast")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Notifications
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            if newValue && !dataManager.notificationManager.isAuthorized {
                                showingNotificationAlert = true
                            }
                        }
                    
                    if notificationsEnabled {
                        Toggle("Sound", isOn: $soundEnabled)
                        Toggle("Haptic Feedback", isOn: $hapticEnabled)
                        
                        if !dataManager.notificationManager.isAuthorized {
                            Label("Notifications disabled in System Settings", systemImage: "exclamationmark.triangle")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // App Settings
                Section("App Settings") {
                    HStack {
                        Label("App Icon", systemImage: "app.fill")
                        Spacer()
                        Text("Default")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Theme", systemImage: "paintbrush.fill")
                        Spacer()
                        Text("System")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Data Management
                Section("Data") {
                    Button {
                        // Export data action
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        // Clear completed tasks action
                    } label: {
                        Label("Clear Completed Tasks", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                // Support
                Section("Support") {
                    Link(destination: URL(string: "https://github.com/RicGue02/LifeOS")!) {
                        HStack {
                            Label("GitHub Repository", systemImage: "link")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button {
                        showingAbout = true
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                    
                    Button {
                        showingPrivacy = true
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                }
                
                // Version Info
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingPrivacy) {
                PrivacyView()
            }
            .alert("Enable Notifications", isPresented: $showingNotificationAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    notificationsEnabled = false
                }
            } message: {
                Text("To receive reminders for tasks and habits, please enable notifications in Settings.")
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "app.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
                    .padding(.top, 40)
                
                Text("Life OS")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your personal productivity companion")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(
                        icon: "checklist",
                        title: "Task Management",
                        description: "Organize your tasks with priorities and due dates"
                    )
                    
                    FeatureRow(
                        icon: "repeat.circle.fill",
                        title: "Habit Tracking",
                        description: "Build and maintain healthy habits"
                    )
                    
                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Statistics",
                        description: "Track your productivity over time"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                Text("Made with ❤️ using SwiftUI")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PrivacySection(
                            title: "Data Collection",
                            content: "Life OS stores all your data locally on your device. We do not collect, transmit, or store any personal information on external servers."
                        )
                        
                        PrivacySection(
                            title: "Data Storage",
                            content: "Your tasks, habits, and settings are stored using Apple's secure storage mechanisms. This data remains on your device and is included in your iCloud backups if enabled."
                        )
                        
                        PrivacySection(
                            title: "Third-Party Services",
                            content: "Life OS does not use any third-party analytics, tracking, or advertising services. Your privacy is our priority."
                        )
                        
                        PrivacySection(
                            title: "Data Sharing",
                            content: "We do not share, sell, or transmit your data to any third parties. Your information stays private and under your control."
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PrivacySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}