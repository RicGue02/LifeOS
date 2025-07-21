//
//  StatsView.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedPeriod: Period = .week
    
    enum Period: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var completionData: [DailyCompletion] {
        let calendar = Calendar.current
        var data: [DailyCompletion] = []
        
        let days: Int = {
            switch selectedPeriod {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }()
        
        for dayOffset in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let completedCount = dataManager.taskStore.tasks.filter { task in
                    task.isCompleted && calendar.isDate(task.updatedAt, inSameDayAs: date)
                }.count
                
                data.append(DailyCompletion(date: date, count: completedCount))
            }
        }
        
        return data.reversed()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Period Selector
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(Period.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Overview Cards
                    HStack(spacing: 16) {
                        OverviewCard(
                            title: "Total Tasks",
                            value: "\(dataManager.taskStore.tasks.count)",
                            icon: "checklist",
                            color: .blue
                        )
                        
                        OverviewCard(
                            title: "Completed",
                            value: "\(dataManager.taskStore.completedTasks.count)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        OverviewCard(
                            title: "Completion Rate",
                            value: "\(completionRate)%",
                            icon: "percent",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // Completion Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Task Completions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart(completionData) { item in
                            BarMark(
                                x: .value("Date", item.date, unit: .day),
                                y: .value("Tasks", item.count)
                            )
                            .foregroundStyle(.blue.gradient)
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                    }
                    
                    // Priority Distribution
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Priority Distribution")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            ForEach(TaskItem.Priority.allCases, id: \.self) { priority in
                                VStack(spacing: 8) {
                                    Text("\(taskCount(for: priority))")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Label(priority.title, systemImage: "flag.fill")
                                        .font(.caption)
                                        .foregroundColor(priority.color)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(recentTasks) { task in
                                HStack {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(task.isCompleted ? .green : .gray)
                                    
                                    VStack(alignment: .leading) {
                                        Text(task.title)
                                            .font(.subheadline)
                                        Text(task.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
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
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
        }
    }
    
    private var completionRate: Int {
        guard !dataManager.taskStore.tasks.isEmpty else { return 0 }
        return Int((Double(dataManager.taskStore.completedTasks.count) / Double(dataManager.taskStore.tasks.count)) * 100)
    }
    
    private func taskCount(for priority: TaskItem.Priority) -> Int {
        dataManager.taskStore.tasks.filter { $0.priority == priority }.count
    }
    
    private var recentTasks: [TaskItem] {
        dataManager.taskStore.tasks
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(5)
            .map { $0 }
    }
}

struct DailyCompletion: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct OverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}