//
//  AddTimeBlockView.swift
//  Life OS
//
//  Created by Assistant on 22/7/25.
//

import SwiftUI

struct AddTimeBlockView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    let selectedDate: Date
    
    @State private var title = ""
    @State private var category: BlockCategory = .work
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600) // 1 hour later
    @State private var notes = ""
    @State private var selectedTask: TaskItem?
    @State private var showingTaskPicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        
        // Set default start time to next available slot
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        
        if calendar.isDateInToday(selectedDate) {
            // If today, start from next hour
            let now = Date()
            let hour = calendar.component(.hour, from: now)
            components.hour = hour + 1
            components.minute = 0
        } else {
            // If future date, start at 9 AM
            components.hour = 9
            components.minute = 0
        }
        
        if let defaultStart = calendar.date(from: components) {
            _startTime = State(initialValue: defaultStart)
            _endTime = State(initialValue: defaultStart.addingTimeInterval(3600))
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Title Section
                Section {
                    TextField("Title", text: $title)
                    
                    Button(action: { showingTaskPicker = true }) {
                        HStack {
                            Label("Link to Task", systemImage: "link")
                            Spacer()
                            if let task = selectedTask {
                                Text(task.title)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                
                // Category Section
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(BlockCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Time Section
                Section("Time") {
                    DatePicker(
                        "Start",
                        selection: $startTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    
                    DatePicker(
                        "End",
                        selection: $endTime,
                        in: startTime...,
                        displayedComponents: [.hourAndMinute]
                    )
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(durationString)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Quick Duration Buttons
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach([15, 30, 45, 60, 90, 120], id: \.self) { minutes in
                                Button(action: {
                                    setDuration(minutes: minutes)
                                }) {
                                    Text("\(minutes)m")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.accentColor.opacity(0.1))
                                        .cornerRadius(15)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                // Notes Section
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle("New Time Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addTimeBlock()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingTaskPicker) {
                TaskPickerView(selectedTask: $selectedTask)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: selectedTask) { newTask in
                if let task = newTask {
                    title = task.title
                    category = mapTaskPriorityToBlockCategory(task.priority)
                }
            }
        }
    }
    
    private var durationString: String {
        let duration = endTime.timeIntervalSince(startTime)
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func setDuration(minutes: Int) {
        endTime = startTime.addingTimeInterval(TimeInterval(minutes * 60))
    }
    
    private func mapTaskPriorityToBlockCategory(_ priority: TaskItem.Priority) -> BlockCategory {
        switch priority {
        case .high:
            return .work  // High priority tasks are usually work
        case .medium:
            return .personal  // Medium priority could be personal
        case .low:
            return .other  // Low priority for other tasks
        }
    }
    
    private func addTimeBlock() {
        let block = TimeBlock(
            title: title,
            startTime: startTime,
            endTime: endTime,
            category: category,
            taskId: selectedTask?.id,
            notes: notes
        )
        
        do {
            try dataManager.dailyStore.addTimeBlock(block, to: selectedDate)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

// Task Picker View
struct TaskPickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @Binding var selectedTask: TaskItem?
    
    private var uncompletedTasks: [TaskItem] {
        dataManager.taskStore.tasks.filter { !$0.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if uncompletedTasks.isEmpty {
                    ContentUnavailableView(
                        "No Tasks Available",
                        systemImage: "checklist",
                        description: Text("Create tasks first to link them to time blocks")
                    )
                } else {
                    ForEach(uncompletedTasks) { task in
                        Button(action: {
                            selectedTask = task
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(task.title)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    if let dueDate = task.dueDate {
                                        Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "flag.fill")
                                    .font(.caption)
                                    .foregroundColor(task.priority.color)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}