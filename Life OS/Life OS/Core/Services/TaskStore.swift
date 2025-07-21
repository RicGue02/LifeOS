//
//  TaskStore.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import Foundation
import Combine

@MainActor
class TaskStore: ObservableObject {
    @Published var tasks: [Task] = []
    
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "com.lifeos.tasks"
    
    init() {
        loadTasks()
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = task
            updatedTask.updatedAt = Date()
            tasks[index] = updatedTask
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updateTask(updatedTask)
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = userDefaults.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
    
    var incompleteTasks: [Task] {
        tasks.filter { !$0.isCompleted }
            .sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
            .sorted { $0.updatedAt > $1.updatedAt }
    }
}