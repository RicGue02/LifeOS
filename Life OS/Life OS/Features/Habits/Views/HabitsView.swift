//
//  HabitsView.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI

struct HabitsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Active Habits
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Habits")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(dataManager.habitStore.activeHabits) { habit in
                            HabitCard(habit: habit) {
                                dataManager.habitStore.toggleHabitCompletion(habit)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Stats Summary
                    HStack(spacing: 16) {
                        StatsSummaryCard(
                            title: "Total Habits",
                            value: "\(dataManager.habitStore.activeHabits.count)",
                            icon: "star.fill",
                            color: .yellow
                        )
                        
                        StatsSummaryCard(
                            title: "Completed Today",
                            value: "\(dataManager.habitStore.completedToday)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    if dataManager.habitStore.habits.isEmpty {
                        ContentUnavailableView(
                            "No Habits",
                            systemImage: "repeat.circle",
                            description: Text("Start building good habits by tapping +")
                        )
                        .padding(.top, 50)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
                    .environmentObject(dataManager)
            }
        }
    }
}

struct HabitCard: View {
    let habit: Habit
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            // Icon and Info
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(habit.swiftUIColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: habit.icon)
                        .font(.title2)
                        .foregroundColor(habit.swiftUIColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Label("\(habit.currentStreak)", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text(habit.frequency.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Completion Button
            Button(action: onToggle) {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(habit.isCompletedToday ? .green : .gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatsSummaryCard: View {
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
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AddHabitView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "blue"
    @State private var frequency: Habit.Frequency = .daily
    @State private var targetCount = 1
    
    let icons = ["star.fill", "heart.fill", "book.fill", "figure.run", "drop.fill", "moon.fill", "sun.max.fill", "leaf.fill"]
    let colors = ["blue", "red", "green", "orange", "purple", "pink", "yellow", "indigo"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Details") {
                    TextField("Name", text: $name)
                    TextField("Description (optional)", text: $description)
                }
                
                Section("Icon & Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? .white : .primary)
                                        .frame(width: 44, height: 44)
                                        .background(selectedIcon == icon ? Color.accentColor : Color(.systemGray5))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(colors, id: \.self) { color in
                                Button {
                                    selectedColor = color
                                } label: {
                                    Circle()
                                        .fill(Color(color))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("Frequency") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(Habit.Frequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if frequency == .daily {
                        Stepper("Target: \(targetCount) times", value: $targetCount, in: 1...10)
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newHabit = Habit(
                            name: name,
                            description: description,
                            icon: selectedIcon,
                            color: selectedColor,
                            frequency: frequency,
                            targetCount: targetCount
                        )
                        dataManager.habitStore.addHabit(newHabit)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}