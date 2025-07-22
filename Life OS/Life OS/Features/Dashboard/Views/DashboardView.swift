//
//  DashboardView.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var currentDate = Date()
    
    private var todaysTasks: [TaskItem] {
        dataManager.todaysTasks
    }
    
    private var upcomingTasks: [TaskItem] {
        Array(dataManager.upcomingTasks.prefix(3))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Weather and Motivation Widgets
                    HStack(spacing: 12) {
                        WeatherWidget()
                            .frame(maxWidth: .infinity)
                        
                        MotivationWidget()
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    
                    // Daily Progress Widget
                    DailyProgressWidget()
                        .padding(.horizontal)
                    
                    // Character and Stats
                    HStack(spacing: 16) {
                        // Character Card
                        VStack(spacing: 12) {
                            MiniHexagonView(
                                dimensions: dataManager.characterStore.character.dimensions,
                                size: 80
                            )
                            
                            VStack(spacing: 4) {
                                Text("Character")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("Level \(dataManager.characterStore.character.level)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Quick Stats Grid
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                MiniStatCard(
                                    value: "\(todaysTasks.count)",
                                    label: "Tasks",
                                    icon: "checklist",
                                    color: .blue
                                )
                                
                                MiniStatCard(
                                    value: "\(dataManager.taskStore.completedTasks.count)",
                                    label: "Done",
                                    icon: "checkmark.circle.fill",
                                    color: .green
                                )
                            }
                            
                            HStack(spacing: 12) {
                                MiniStatCard(
                                    value: "\(dataManager.habitStore.habits.count)",
                                    label: "Habits",
                                    icon: "repeat",
                                    color: .orange
                                )
                                
                                MiniStatCard(
                                    value: String(format: "%.0f%%", dataManager.financeStore.savingsRate * 100),
                                    label: "Savings",
                                    icon: "percent",
                                    color: .purple
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    
                    // Finance Summary
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Finance Overview", systemImage: "dollarsign.circle")
                        
                        HStack(spacing: 16) {
                            FinanceCard(
                                title: "Balance",
                                value: String(format: "$%.0f", dataManager.financeStore.currentBalance),
                                trend: dataManager.financeStore.savingsRate > 0 ? .up : .down
                            )
                            
                            FinanceCard(
                                title: "This Month",
                                value: String(format: "$%.0f", dataManager.financeStore.monthlyIncome - dataManager.financeStore.monthlyExpenses),
                                trend: dataManager.financeStore.monthlyIncome > dataManager.financeStore.monthlyExpenses ? .up : .down
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Today's Tasks
                    if !todaysTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Today's Tasks", systemImage: "calendar")
                            
                            ForEach(todaysTasks) { task in
                                TaskCard(task: task) {
                                    dataManager.taskStore.toggleTaskCompletion(task)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Upcoming Tasks
                    if !upcomingTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Upcoming", systemImage: "calendar.badge.clock")
                            
                            ForEach(upcomingTasks) { task in
                                TaskCard(task: task) {
                                    dataManager.taskStore.toggleTaskCompletion(task)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Empty State
                    if todaysTasks.isEmpty && upcomingTasks.isEmpty {
                        ContentUnavailableView(
                            "No Tasks Scheduled",
                            systemImage: "calendar.badge.checkmark",
                            description: Text("You're all caught up!")
                        )
                        .padding(.top, 50)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Life OS")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TaskCard: View {
    let task: TaskItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted)
                
                if let dueDate = task.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "flag.fill")
                .font(.caption)
                .foregroundColor(task.priority.color)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct SectionHeader: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
            Spacer()
        }
    }
}

struct FinanceCard: View {
    let title: String
    let value: String
    let trend: Trend
    
    enum Trend {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.circle.fill"
            case .down: return "arrow.down.circle.fill"
            case .neutral: return "minus.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .gray
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .font(.caption)
                    .foregroundColor(trend.color)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct MiniStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}