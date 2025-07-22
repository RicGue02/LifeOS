//
//  TimeBlockDetailView.swift
//  Life OS
//
//  Created by Assistant on 22/7/25.
//

import SwiftUI

struct TimeBlockDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    let timeBlock: TimeBlock
    let date: Date
    
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedCategory: BlockCategory
    @State private var editedStartTime: Date
    @State private var editedEndTime: Date
    @State private var editedNotes: String
    @State private var showingDeleteAlert = false
    
    init(timeBlock: TimeBlock, date: Date) {
        self.timeBlock = timeBlock
        self.date = date
        _editedTitle = State(initialValue: timeBlock.title)
        _editedCategory = State(initialValue: timeBlock.category)
        _editedStartTime = State(initialValue: timeBlock.startTime)
        _editedEndTime = State(initialValue: timeBlock.endTime)
        _editedNotes = State(initialValue: timeBlock.notes)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(spacing: 16) {
                        // Category Icon
                        Image(systemName: timeBlock.category.icon)
                            .font(.largeTitle)
                            .foregroundColor(timeBlock.category.color)
                            .frame(width: 60, height: 60)
                            .background(timeBlock.category.color.opacity(0.1))
                            .clipShape(Circle())
                        
                        // Title
                        if isEditing {
                            TextField("Title", text: $editedTitle)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(timeBlock.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        
                        // Status
                        HStack(spacing: 12) {
                            Label(
                                timeBlock.isCompleted ? "Completed" : "Scheduled",
                                systemImage: timeBlock.isCompleted ? "checkmark.circle.fill" : "clock"
                            )
                            .font(.caption)
                            .foregroundColor(timeBlock.isCompleted ? .green : .orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                (timeBlock.isCompleted ? Color.green : Color.orange).opacity(0.1)
                            )
                            .cornerRadius(20)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Details Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Category
                        if isEditing {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Category", systemImage: "tag")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Category", selection: $editedCategory) {
                                    ForEach(BlockCategory.allCases, id: \.self) { cat in
                                        Label(cat.rawValue, systemImage: cat.icon)
                                            .tag(cat)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        }
                        
                        // Time
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Time", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if isEditing {
                                DatePicker(
                                    "Start",
                                    selection: $editedStartTime,
                                    displayedComponents: [.hourAndMinute]
                                )
                                
                                DatePicker(
                                    "End",
                                    selection: $editedEndTime,
                                    in: editedStartTime...,
                                    displayedComponents: [.hourAndMinute]
                                )
                            } else {
                                Text(timeBlock.timeRangeString)
                                    .font(.body)
                                
                                Text("Duration: \(timeBlock.durationString)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Notes", systemImage: "note.text")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if isEditing {
                                TextEditor(text: $editedNotes)
                                    .frame(minHeight: 80)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            } else if !timeBlock.notes.isEmpty {
                                Text(timeBlock.notes)
                                    .font(.body)
                            } else {
                                Text("No notes")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Linked Task
                        if let taskId = timeBlock.taskId,
                           let task = dataManager.taskStore.tasks.first(where: { $0.id == taskId }) {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Linked Task", systemImage: "link")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(task.title)
                                            .font(.subheadline)
                                        
                                        if let dueDate = task.dueDate {
                                            Text("Due: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                                                .font(.caption)
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
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Action Buttons
                    if !isEditing {
                        VStack(spacing: 12) {
                            Button(action: toggleCompletion) {
                                Label(
                                    timeBlock.isCompleted ? "Mark as Incomplete" : "Mark as Complete",
                                    systemImage: timeBlock.isCompleted ? "xmark.circle" : "checkmark.circle"
                                )
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(timeBlock.isCompleted ? .orange : .green)
                            
                            Button(action: { showingDeleteAlert = true }) {
                                Label("Delete", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Time Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isEditing {
                        Button("Cancel") {
                            resetEditing()
                        }
                    } else {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            saveChanges()
                        }
                        .fontWeight(.semibold)
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
            }
            .alert("Delete Time Block", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteTimeBlock()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this time block?")
            }
        }
    }
    
    private func toggleCompletion() {
        dataManager.dailyStore.toggleTimeBlockCompletion(timeBlock, for: date)
        dismiss()
    }
    
    private func saveChanges() {
        var updatedBlock = timeBlock
        updatedBlock.title = editedTitle
        updatedBlock.category = editedCategory
        updatedBlock.startTime = editedStartTime
        updatedBlock.endTime = editedEndTime
        updatedBlock.notes = editedNotes
        updatedBlock.updatedAt = Date()
        
        dataManager.dailyStore.updateTimeBlock(updatedBlock, for: date)
        isEditing = false
        dismiss()
    }
    
    private func resetEditing() {
        editedTitle = timeBlock.title
        editedCategory = timeBlock.category
        editedStartTime = timeBlock.startTime
        editedEndTime = timeBlock.endTime
        editedNotes = timeBlock.notes
        isEditing = false
    }
    
    private func deleteTimeBlock() {
        dataManager.dailyStore.deleteTimeBlock(timeBlock, from: date)
        dismiss()
    }
}