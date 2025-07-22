//
//  DataManager.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class DataManager: ObservableObject {
    @Published var taskStore: TaskStore
    @Published var habitStore: HabitStore
    @Published var characterStore: CharacterStore
    @Published var financeStore: FinanceStore
    let notificationManager = NotificationManager.shared
    
    init() {
        self.taskStore = TaskStore()
        self.habitStore = HabitStore()
        self.characterStore = CharacterStore()
        self.financeStore = FinanceStore()
        setupNotifications()
        setupCharacterTracking()
    }
    
    private func setupNotifications() {
        notificationManager.setupNotificationActions()
    }
    
    private func setupCharacterTracking() {
        // Track task completions
        taskStore.$tasks
            .sink { [weak self] _ in
                self?.updateCharacterFromTasks()
            }
            .store(in: &cancellables)
        
        // Track habit completions
        habitStore.$habits
            .sink { [weak self] _ in
                self?.updateCharacterFromHabits()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func updateCharacterFromTasks() {
        // This will be called when tasks change
    }
    
    private func updateCharacterFromHabits() {
        // This will be called when habits change
    }
    
    // Dashboard Statistics
    var todaysTasks: [TaskItem] {
        taskStore.incompleteTasks.filter { task in
            if let dueDate = task.dueDate {
                return Calendar.current.isDateInToday(dueDate)
            }
            return false
        }
    }
    
    var upcomingTasks: [TaskItem] {
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