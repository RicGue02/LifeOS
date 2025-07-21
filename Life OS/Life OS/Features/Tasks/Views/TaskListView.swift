//
//  TaskListView.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var viewModel = TaskListViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                if !viewModel.filteredIncompleteTasks.isEmpty {
                    Section("Pending") {
                        ForEach(viewModel.filteredIncompleteTasks) { task in
                            TaskRowView(task: task) {
                                viewModel.toggleTaskCompletion(task)
                                if !task.isCompleted {
                                    dataManager.characterStore.completeTask(priority: task.priority)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteTask(task)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                
                if !viewModel.filteredCompletedTasks.isEmpty {
                    Section("Completed") {
                        ForEach(viewModel.filteredCompletedTasks) { task in
                            TaskRowView(task: task) {
                                viewModel.toggleTaskCompletion(task)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteTask(task)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddTask) {
                AddTaskView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.taskStore = dataManager.taskStore
            }
            .overlay {
                if viewModel.taskStore.tasks.isEmpty {
                    ContentUnavailableView(
                        "No Tasks",
                        systemImage: "checklist",
                        description: Text("Tap + to add your first task")
                    )
                }
            }
        }
    }
}