//
//  Character.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import Foundation
import SwiftUI

struct Character: Codable {
    var level: Int
    var experience: Int
    var dimensions: LifeDimensions
    var lastUpdated: Date
    
    init() {
        self.level = 1
        self.experience = 0
        self.dimensions = LifeDimensions()
        self.lastUpdated = Date()
    }
    
    var totalScore: Double {
        dimensions.averageScore
    }
    
    var experienceForNextLevel: Int {
        level * 100
    }
    
    var experienceProgress: Double {
        Double(experience) / Double(experienceForNextLevel)
    }
    
    mutating func addExperience(_ points: Int) {
        experience += points
        while experience >= experienceForNextLevel {
            experience -= experienceForNextLevel
            level += 1
        }
        lastUpdated = Date()
    }
}

struct LifeDimensions: Codable {
    var health: Dimension
    var wealth: Dimension
    var relationships: Dimension
    var career: Dimension
    var personal: Dimension
    var fun: Dimension
    
    init() {
        self.health = Dimension(name: "Health", icon: "heart.fill", color: .red)
        self.wealth = Dimension(name: "Wealth", icon: "dollarsign.circle.fill", color: .green)
        self.relationships = Dimension(name: "Relations", icon: "person.2.fill", color: .blue)
        self.career = Dimension(name: "Career", icon: "briefcase.fill", color: .orange)
        self.personal = Dimension(name: "Personal", icon: "brain", color: .purple)
        self.fun = Dimension(name: "Fun", icon: "gamecontroller.fill", color: .pink)
    }
    
    var allDimensions: [Dimension] {
        [health, wealth, relationships, career, personal, fun]
    }
    
    var averageScore: Double {
        let total = health.score + wealth.score + relationships.score + 
                   career.score + personal.score + fun.score
        return total / 6.0
    }
    
    mutating func updateDimension(_ type: DimensionType, score: Double) {
        switch type {
        case .health:
            health.score = min(100, max(0, score))
        case .wealth:
            wealth.score = min(100, max(0, score))
        case .relationships:
            relationships.score = min(100, max(0, score))
        case .career:
            career.score = min(100, max(0, score))
        case .personal:
            personal.score = min(100, max(0, score))
        case .fun:
            fun.score = min(100, max(0, score))
        }
    }
}

struct Dimension: Codable, Identifiable {
    var id = UUID()
    let name: String
    let icon: String
    let colorName: String
    var score: Double = 50.0
    
    init(name: String, icon: String, color: Color) {
        self.name = name
        self.icon = icon
        self.colorName = color.description
        self.score = 50.0
    }
    
    var color: Color {
        switch colorName {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        default: return .gray
        }
    }
    
    var level: String {
        switch score {
        case 0..<20:
            return "Critical"
        case 20..<40:
            return "Poor"
        case 40..<60:
            return "Average"
        case 60..<80:
            return "Good"
        case 80...100:
            return "Excellent"
        default:
            return "Unknown"
        }
    }
}

enum DimensionType: String, CaseIterable {
    case health = "Health"
    case wealth = "Wealth"
    case relationships = "Relations"
    case career = "Career"
    case personal = "Personal"
    case fun = "Fun"
}