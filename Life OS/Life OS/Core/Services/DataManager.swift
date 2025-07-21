//
//  DataManager.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import Foundation
import SwiftUI

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var taskStore: TaskStore
    @Published var habitStore: HabitStore
    let notificationManager = NotificationManager.shared
    
    private init() {
        self.taskStore = TaskStore()
        self.habitStore = HabitStore()
        setupNotifications()
    }
    
    private func setupNotifications() {
        notificationManager.setupNotificationActions()
    }
    
    // Dashboard Statistics
    var todaysTasks: [Task] {
        taskStore.incompleteTasks.filter { task in
            if let dueDate = task.dueDate {
                return Calendar.current.isDateInToday(dueDate)
            }
            return false
        }
    }
    
    var upcomingTasks: [Task] {
        taskStore.incompleteTasks
            .filter { $0.dueDate != nil }
            .sorted { ($0.dueDate ?? Date()) < ($1.dueDate ?? Date()) }
            .prefix(5)
            .map { $0 }
    }
    
    var completionRate: Double {
        guard !taskStore.tasks.isEmpty else { return 0 }
        return Double(taskStore.completedTasks.count) / Double(taskStore.tasks.count)
    }
    
    // Weekly Statistics
    func tasksCompleted(in days: Int) -> [DailyTaskCount] {
        let calendar = Calendar.current
        var counts: [DailyTaskCount] = []
        
        for dayOffset in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let count = taskStore.tasks.filter { task in
                    task.isCompleted && calendar.isDate(task.updatedAt, inSameDayAs: date)
                }.count
                
                counts.append(DailyTaskCount(date: date, count: count))
            }
        }
        
        return counts.reversed()
    }
    
    func habitsCompleted(in days: Int) -> [DailyHabitCount] {
        let calendar = Calendar.current
        var counts: [DailyHabitCount] = []
        
        for dayOffset in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let count = habitStore.habits.flatMap { $0.completions }.filter { completion in
                    calendar.isDate(completion.date, inSameDayAs: date)
                }.count
                
                counts.append(DailyHabitCount(date: date, count: count))
            }
        }
        
        return counts.reversed()
    }
}

struct DailyTaskCount: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct DailyHabitCount: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}