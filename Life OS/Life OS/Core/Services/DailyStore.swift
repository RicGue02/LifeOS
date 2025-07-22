//
//  DailyStore.swift
//  Life OS
//
//  Created by Assistant on 22/7/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DailyStore: ObservableObject {
    @Published var schedules: [Date: DailySchedule] = [:]
    @Published var currentDate = Date()
    
    private let saveKey = "DailySchedules"
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSchedules()
    }
    
    // MARK: - Current Day Management
    
    var todaySchedule: DailySchedule {
        let today = Calendar.current.startOfDay(for: Date())
        if let schedule = schedules[today] {
            return schedule
        } else {
            let newSchedule = DailySchedule(date: today)
            schedules[today] = newSchedule
            saveSchedules()
            return newSchedule
        }
    }
    
    func getSchedule(for date: Date) -> DailySchedule {
        let day = Calendar.current.startOfDay(for: date)
        if let schedule = schedules[day] {
            return schedule
        } else {
            let newSchedule = DailySchedule(date: day)
            schedules[day] = newSchedule
            saveSchedules()
            return newSchedule
        }
    }
    
    // MARK: - Time Block Management
    
    func addTimeBlock(_ block: TimeBlock, to date: Date) throws {
        let day = Calendar.current.startOfDay(for: date)
        var schedule = getSchedule(for: day)
        
        // Validate time range
        if block.endTime <= block.startTime {
            throw TimeBlockError.invalidTimeRange
        }
        
        try schedule.addTimeBlock(block)
        schedules[day] = schedule
        saveSchedules()
    }
    
    func updateTimeBlock(_ block: TimeBlock, for date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        var schedule = getSchedule(for: day)
        
        if let index = schedule.timeBlocks.firstIndex(where: { $0.id == block.id }) {
            schedule.timeBlocks[index] = block
            schedules[day] = schedule
            saveSchedules()
        }
    }
    
    func deleteTimeBlock(_ block: TimeBlock, from date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        var schedule = getSchedule(for: day)
        schedule.removeTimeBlock(block)
        schedules[day] = schedule
        saveSchedules()
    }
    
    func toggleTimeBlockCompletion(_ block: TimeBlock, for date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        var schedule = getSchedule(for: day)
        
        if let index = schedule.timeBlocks.firstIndex(where: { $0.id == block.id }) {
            schedule.timeBlocks[index].isCompleted.toggle()
            schedules[day] = schedule
            saveSchedules()
        }
    }
    
    // MARK: - Daily Review Management
    
    func saveDailyReview(_ review: DailyReview, for date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        var schedule = getSchedule(for: day)
        schedule.dailyReview = review
        schedules[day] = schedule
        saveSchedules()
    }
    
    // MARK: - Quick Add Functions
    
    func addTaskBlock(task: TaskItem, startTime: Date, duration: TimeInterval) throws {
        let endTime = startTime.addingTimeInterval(duration)
        
        // Map priority to category (since TaskItem doesn't have category)
        let category: BlockCategory = {
            switch task.priority {
            case .high:
                return .work  // High priority tasks are usually work
            case .medium:
                return .personal  // Medium priority could be personal
            case .low:
                return .other  // Low priority for other tasks
            }
        }()
        
        let block = TimeBlock(
            title: task.title,
            startTime: startTime,
            endTime: endTime,
            category: category,
            taskId: task.id,
            notes: task.description
        )
        
        try addTimeBlock(block, to: startTime)
    }
    
    func suggestTimeBlock(for duration: TimeInterval, after date: Date) -> Date? {
        let schedule = getSchedule(for: date)
        let sortedBlocks = schedule.sortedTimeBlocks
        
        // Start from the given date or the current time if it's today
        var suggestedStart = date
        if Calendar.current.isDateInToday(date) {
            suggestedStart = max(date, Date())
        }
        
        // Round to next 15 minutes
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: suggestedStart)
        let roundedMinute = ((minute / 15) + 1) * 15
        if let rounded = calendar.date(bySettingHour: calendar.component(.hour, from: suggestedStart),
                                       minute: roundedMinute % 60,
                                       second: 0,
                                       of: suggestedStart) {
            suggestedStart = rounded
        }
        
        // Check if there's a conflict with existing blocks
        let suggestedEnd = suggestedStart.addingTimeInterval(duration)
        let testBlock = TimeBlock(
            title: "Test",
            startTime: suggestedStart,
            endTime: suggestedEnd,
            category: .other
        )
        
        for block in sortedBlocks {
            if testBlock.overlaps(with: block) {
                // Try after this block
                suggestedStart = block.endTime
                // Round to next 15 minutes
                let minute = calendar.component(.minute, from: suggestedStart)
                let roundedMinute = ((minute / 15) + 1) * 15
                if let rounded = calendar.date(bySettingHour: calendar.component(.hour, from: suggestedStart),
                                               minute: roundedMinute % 60,
                                               second: 0,
                                               of: suggestedStart) {
                    suggestedStart = rounded
                }
            }
        }
        
        return suggestedStart
    }
    
    // MARK: - Statistics
    
    func getStatistics(for date: Date) -> DailyStatistics {
        let schedule = getSchedule(for: date)
        
        var categoryMinutes: [BlockCategory: Int] = [:]
        var completedMinutes = 0
        var totalMinutes = 0
        
        for block in schedule.timeBlocks {
            let minutes = block.durationInMinutes
            categoryMinutes[block.category, default: 0] += minutes
            totalMinutes += minutes
            if block.isCompleted {
                completedMinutes += minutes
            }
        }
        
        return DailyStatistics(
            totalBlocks: schedule.timeBlocks.count,
            completedBlocks: schedule.timeBlocks.filter { $0.isCompleted }.count,
            totalMinutes: totalMinutes,
            completedMinutes: completedMinutes,
            categoryBreakdown: categoryMinutes,
            completionRate: schedule.completionRate
        )
    }
    
    // MARK: - Persistence
    
    private func loadSchedules() {
        if let data = userDefaults.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Date: DailySchedule].self, from: data) {
            schedules = decoded
        }
    }
    
    private func saveSchedules() {
        if let encoded = try? JSONEncoder().encode(schedules) {
            userDefaults.set(encoded, forKey: saveKey)
        }
    }
}

struct DailyStatistics {
    let totalBlocks: Int
    let completedBlocks: Int
    let totalMinutes: Int
    let completedMinutes: Int
    let categoryBreakdown: [BlockCategory: Int]
    let completionRate: Double
    
    var totalHours: Double {
        Double(totalMinutes) / 60.0
    }
    
    var completedHours: Double {
        Double(completedMinutes) / 60.0
    }
}