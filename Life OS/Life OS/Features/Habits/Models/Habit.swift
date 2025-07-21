//
//  Habit.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import Foundation
import SwiftUI

struct Habit: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var icon: String
    var color: String
    var frequency: Frequency
    var targetCount: Int
    var completions: [HabitCompletion]
    var createdAt: Date
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        icon: String = "star.fill",
        color: String = "blue",
        frequency: Frequency = .daily,
        targetCount: Int = 1,
        completions: [HabitCompletion] = [],
        createdAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.frequency = frequency
        self.targetCount = targetCount
        self.completions = completions
        self.createdAt = createdAt
        self.isActive = isActive
    }
    
    enum Frequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case custom = "Custom"
    }
    
    var currentStreak: Int {
        guard !completions.isEmpty else { return 0 }
        
        let sortedCompletions = completions.sorted { $0.date > $1.date }
        var streak = 0
        let calendar = Calendar.current
        var checkDate = Date()
        
        for completion in sortedCompletions {
            if calendar.isDate(completion.date, inSameDayAs: checkDate) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if let daysDiff = calendar.dateComponents([.day], from: completion.date, to: checkDate).day,
                      daysDiff == 1 {
                streak += 1
                checkDate = completion.date
            } else {
                break
            }
        }
        
        return streak
    }
    
    var isCompletedToday: Bool {
        completions.contains { completion in
            Calendar.current.isDateInToday(completion.date)
        }
    }
    
    var swiftUIColor: Color {
        Color(color)
    }
}

struct HabitCompletion: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let count: Int
    
    init(id: UUID = UUID(), date: Date = Date(), count: Int = 1) {
        self.id = id
        self.date = date
        self.count = count
    }
}