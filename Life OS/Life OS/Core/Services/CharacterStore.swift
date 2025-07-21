//
//  CharacterStore.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class CharacterStore: ObservableObject {
    @Published var character: Character
    
    private let userDefaults = UserDefaults.standard
    private let characterKey = "com.lifeos.character"
    
    init() {
        if let data = userDefaults.data(forKey: characterKey),
           let decoded = try? JSONDecoder().decode(Character.self, from: data) {
            self.character = decoded
        } else {
            self.character = Character()
            saveCharacter()
        }
    }
    
    func updateDimensionScore(_ type: DimensionType, score: Double) {
        character.dimensions.updateDimension(type, score: score)
        
        // Add experience based on improvement
        let improvement = Int(abs(score - 50) / 10)
        if improvement > 0 {
            character.addExperience(improvement * 10)
        }
        
        saveCharacter()
    }
    
    func addExperience(_ points: Int) {
        character.addExperience(points)
        saveCharacter()
    }
    
    func completeTask(priority: TaskItem.Priority) {
        let points = switch priority {
        case .low: 5
        case .medium: 10
        case .high: 20
        }
        addExperience(points)
    }
    
    func completeHabit() {
        addExperience(15)
    }
    
    private func saveCharacter() {
        if let encoded = try? JSONEncoder().encode(character) {
            userDefaults.set(encoded, forKey: characterKey)
        }
    }
    
    // Calculate dimension scores based on user activity
    func calculateHealthScore(from habits: [Habit]) -> Double {
        let healthHabits = habits.filter { 
            $0.name.lowercased().contains("exercise") ||
            $0.name.lowercased().contains("water") ||
            $0.name.lowercased().contains("sleep") ||
            $0.name.lowercased().contains("meditat")
        }
        
        guard !healthHabits.isEmpty else { return 50.0 }
        
        let completionRate = healthHabits.map { habit in
            let recentCompletions = habit.completions.filter { 
                $0.date.timeIntervalSinceNow > -7 * 24 * 60 * 60 // Last 7 days
            }.count
            return Double(recentCompletions) / 7.0
        }.reduce(0, +) / Double(healthHabits.count)
        
        return 50.0 + (completionRate * 50.0)
    }
    
    func calculateWealthScore(monthlyIncome: Double, monthlyExpenses: Double) -> Double {
        guard monthlyIncome > 0 else { return 50.0 }
        
        let savingsRate = (monthlyIncome - monthlyExpenses) / monthlyIncome
        let score = 50.0 + (savingsRate * 100.0)
        
        return min(100, max(0, score))
    }
    
    func calculateCareerScore(tasksCompleted: Int, totalTasks: Int) -> Double {
        guard totalTasks > 0 else { return 50.0 }
        
        let completionRate = Double(tasksCompleted) / Double(totalTasks)
        return 30.0 + (completionRate * 70.0)
    }
}