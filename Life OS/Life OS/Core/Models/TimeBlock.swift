//
//  TimeBlock.swift
//  Life OS
//
//  Created by Assistant on 22/7/25.
//

import Foundation
import SwiftUI

struct TimeBlock: Identifiable, Codable {
    let id: UUID
    var title: String
    var startTime: Date
    var endTime: Date
    var category: BlockCategory
    var taskId: UUID?  // Optional link to a task
    var color: String
    var notes: String
    var isCompleted: Bool
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        startTime: Date,
        endTime: Date,
        category: BlockCategory,
        taskId: UUID? = nil,
        notes: String = "",
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
        self.taskId = taskId
        self.color = category.colorName
        self.notes = notes
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var durationInMinutes: Int {
        Int(duration / 60)
    }
    
    var durationString: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var timeRangeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    func overlaps(with other: TimeBlock) -> Bool {
        return (startTime < other.endTime) && (endTime > other.startTime)
    }
}

enum BlockCategory: String, CaseIterable, Codable {
    case work = "Work"
    case personal = "Personal"
    case health = "Health"
    case learning = "Learning"
    case social = "Social"
    case rest = "Break"
    case commute = "Commute"
    case meal = "Meal"
    case planning = "Planning"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .health: return "heart.fill"
        case .learning: return "book.fill"
        case .social: return "person.2.fill"
        case .rest: return "pause.circle.fill"
        case .commute: return "car.fill"
        case .meal: return "fork.knife"
        case .planning: return "calendar"
        case .other: return "square.grid.2x2"
        }
    }
    
    var color: Color {
        switch self {
        case .work: return .blue
        case .personal: return .purple
        case .health: return .red
        case .learning: return .orange
        case .social: return .green
        case .rest: return .gray
        case .commute: return .indigo
        case .meal: return .yellow
        case .planning: return .teal
        case .other: return .secondary
        }
    }
    
    var colorName: String {
        switch self {
        case .work: return "blue"
        case .personal: return "purple"
        case .health: return "red"
        case .learning: return "orange"
        case .social: return "green"
        case .rest: return "gray"
        case .commute: return "indigo"
        case .meal: return "yellow"
        case .planning: return "teal"
        case .other: return "secondary"
        }
    }
}

// Daily Schedule to hold all time blocks for a day
struct DailySchedule: Codable {
    let date: Date
    var timeBlocks: [TimeBlock]
    var dailyReview: DailyReview?
    
    init(date: Date, timeBlocks: [TimeBlock] = []) {
        self.date = Calendar.current.startOfDay(for: date)
        self.timeBlocks = timeBlocks
        self.dailyReview = nil
    }
    
    var sortedTimeBlocks: [TimeBlock] {
        timeBlocks.sorted { $0.startTime < $1.startTime }
    }
    
    var totalPlannedMinutes: Int {
        timeBlocks.reduce(0) { $0 + $1.durationInMinutes }
    }
    
    var completionRate: Double {
        guard !timeBlocks.isEmpty else { return 0 }
        let completed = timeBlocks.filter { $0.isCompleted }.count
        return Double(completed) / Double(timeBlocks.count)
    }
    
    mutating func addTimeBlock(_ block: TimeBlock) throws {
        // Check for overlaps
        for existingBlock in timeBlocks {
            if block.overlaps(with: existingBlock) {
                throw TimeBlockError.overlappingBlocks
            }
        }
        timeBlocks.append(block)
    }
    
    mutating func removeTimeBlock(_ block: TimeBlock) {
        timeBlocks.removeAll { $0.id == block.id }
    }
}

// Daily Review
struct DailyReview: Codable {
    let id: UUID
    let date: Date
    var accomplishments: String
    var challenges: String
    var lessonsLearned: String
    var tomorrowsPriorities: String
    var gratitude: String
    var moodRating: Int  // 1-5
    var energyRating: Int  // 1-5
    var productivityRating: Int  // 1-5
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        date: Date,
        accomplishments: String = "",
        challenges: String = "",
        lessonsLearned: String = "",
        tomorrowsPriorities: String = "",
        gratitude: String = "",
        moodRating: Int = 3,
        energyRating: Int = 3,
        productivityRating: Int = 3,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.accomplishments = accomplishments
        self.challenges = challenges
        self.lessonsLearned = lessonsLearned
        self.tomorrowsPriorities = tomorrowsPriorities
        self.gratitude = gratitude
        self.moodRating = moodRating
        self.energyRating = energyRating
        self.productivityRating = productivityRating
        self.createdAt = createdAt
    }
}

enum TimeBlockError: LocalizedError {
    case overlappingBlocks
    case invalidTimeRange
    
    var errorDescription: String? {
        switch self {
        case .overlappingBlocks:
            return "This time block overlaps with an existing block"
        case .invalidTimeRange:
            return "End time must be after start time"
        }
    }
}