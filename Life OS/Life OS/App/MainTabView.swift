//
//  MainTabView.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            DailyView()
                .tabItem {
                    Label("Daily", systemImage: "calendar")
                }
                .tag(1)
            
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(2)
            
            CharacterView()
                .tabItem {
                    Label("Character", systemImage: "person.crop.circle.fill")
                }
                .tag(3)
            
            FinanceView()
                .tabItem {
                    Label("Finance", systemImage: "dollarsign.circle.fill")
                }
                .tag(4)
            
            HabitsView()
                .tabItem {
                    Label("Habits", systemImage: "repeat.circle.fill")
                }
                .tag(5)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(6)
        }
        .tint(.accentColor)
    }
}