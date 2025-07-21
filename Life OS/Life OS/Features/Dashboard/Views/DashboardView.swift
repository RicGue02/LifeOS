//
//  DashboardView.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var taskStore = TaskStore()
    @State private var currentDate = Date()
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: currentDate)
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
    
    private var todaysTasks: [Task] {
        taskStore.incompleteTasks.filter { task in
            if let dueDate = task.dueDate {
                return Calendar.current.isDateInToday(dueDate)
            }
            return false
        }
    }
    
    private var upcomingTasks: [Task] {
        taskStore.incompleteTasks
            .filter { $0.dueDate != nil }
            .sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(greeting)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(currentDate.formatted(date: .complete, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Tasks Today",
                            value: "\(todaysTasks.count)",
                            icon: "checklist",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Completed",
                            value: "\(taskStore.completedTasks.count)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Today's Tasks
                    if !todaysTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Today's Tasks", systemImage: "calendar")
                            
                            ForEach(todaysTasks) { task in
                                TaskCard(task: task) {
                                    taskStore.toggleTaskCompletion(task)
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
                                    taskStore.toggleTaskCompletion(task)
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
    let task: Task
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