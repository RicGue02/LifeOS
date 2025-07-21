//
//  TaskListViewModel.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI
import Combine

@MainActor
class TaskListViewModel: ObservableObject {
    @Published var taskStore: TaskStore
    @Published var searchText = ""
    @Published var showingAddTask = false
    @Published var selectedTask: TaskItem?
    
    init(taskStore: TaskStore? = nil) {
        self.taskStore = taskStore ?? TaskStore()
    }
    
    var filteredIncompleteTasks: [TaskItem] {
        if searchText.isEmpty {
            return taskStore.incompleteTasks
        } else {
            return taskStore.incompleteTasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var filteredCompletedTasks: [TaskItem] {
        if searchText.isEmpty {
            return taskStore.completedTasks
        } else {
            return taskStore.completedTasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func addTask(title: String, description: String, priority: TaskItem.Priority, dueDate: Date?) {
        let newTask = TaskItem(
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate
        )
        taskStore.addTask(newTask)
    }
    
    func toggleTaskCompletion(_ task: TaskItem) {
        taskStore.toggleTaskCompletion(task)
    }
    
    func deleteTask(_ task: TaskItem) {
        taskStore.deleteTask(task)
    }
}