//
//  AddTaskView.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskItem.Priority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var enableReminder = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Settings") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskItem.Priority.allCases, id: \.self) { priority in
                            Label(priority.title, systemImage: "flag.fill")
                                .foregroundColor(priority.color)
                                .tag(priority)
                        }
                    }
                    
                    Toggle("Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker(
                            "Date",
                            selection: $dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        
                        Toggle("Reminder", isOn: $enableReminder)
                            .disabled(!dataManager.notificationManager.isAuthorized)
                        
                        if !dataManager.notificationManager.isAuthorized && enableReminder {
                            Label("Enable notifications in Settings", systemImage: "exclamationmark.triangle")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newTask = TaskItem(
                            title: title,
                            description: description,
                            priority: priority,
                            dueDate: hasDueDate ? dueDate : nil
                        )
                        viewModel.taskStore.addTask(newTask)
                        
                        if enableReminder && hasDueDate {
                            _Concurrency.Task {
                                await dataManager.notificationManager.scheduleTaskReminder(for: newTask)
                            }
                        }
                        
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}