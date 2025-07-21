//
//  HabitStore.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import Foundation
import Combine

@MainActor
class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    
    private let userDefaults = UserDefaults.standard
    private let habitsKey = "com.lifeos.habits"
    
    init() {
        loadHabits()
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    
    func toggleHabitCompletion(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        if habits[index].isCompletedToday {
            habits[index].completions.removeAll { completion in
                Calendar.current.isDateInToday(completion.date)
            }
        } else {
            habits[index].completions.append(HabitCompletion())
        }
        saveHabits()
    }
    
    func completeHabit(_ habit: Habit, count: Int = 1) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        let today = Date()
        if let existingIndex = habits[index].completions.firstIndex(where: { 
            Calendar.current.isDateInToday($0.date) 
        }) {
            habits[index].completions[existingIndex] = HabitCompletion(date: today, count: count)
        } else {
            habits[index].completions.append(HabitCompletion(date: today, count: count))
        }
        saveHabits()
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            userDefaults.set(encoded, forKey: habitsKey)
        }
    }
    
    private func loadHabits() {
        if let data = userDefaults.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
    
    var activeHabits: [Habit] {
        habits.filter { $0.isActive }
            .sorted { $0.name < $1.name }
    }
    
    var todaysProgress: Double {
        let active = activeHabits
        guard !active.isEmpty else { return 0 }
        
        let completed = active.filter { $0.isCompletedToday }.count
        return Double(completed) / Double(active.count)
    }
    
    var completedToday: Int {
        activeHabits.filter { $0.isCompletedToday }.count
    }
}