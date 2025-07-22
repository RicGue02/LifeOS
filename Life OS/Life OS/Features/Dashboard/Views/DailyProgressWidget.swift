//
//  DailyProgressWidget.swift
//  Life OS
//
//  Created by Assistant on 22/7/25.
//

import SwiftUI

struct DailyProgressWidget: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var todaysHabits: [(habit: Habit, isCompleted: Bool)] {
        let today = Calendar.current.startOfDay(for: Date())
        return dataManager.habitStore.habits.map { habit in
            let isCompleted = habit.completions.contains { completion in
                Calendar.current.isDate(completion.date, inSameDayAs: today)
            }
            return (habit, isCompleted)
        }
    }
    
    private var completedCount: Int {
        todaysHabits.filter { $0.isCompleted }.count
    }
    
    private var totalCount: Int {
        todaysHabits.count
    }
    
    private var completionRate: Double {
        totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text("Today's Progress")
                    .font(.headline)
                Spacer()
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Daily Habits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(completedCount)/\(totalCount) completed")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(completionRate == 1.0 ? Color.green : Color.blue)
                            .frame(width: geometry.size.width * completionRate, height: 8)
                            .animation(.spring(), value: completionRate)
                    }
                }
                .frame(height: 8)
                
                if completionRate == 1.0 {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("Perfect day! All habits completed!")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Habit List
            if !todaysHabits.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(todaysHabits.prefix(5).enumerated()), id: \.0) { index, item in
                        HStack {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.caption)
                                .foregroundColor(item.isCompleted ? .green : .gray)
                            
                            Text(item.habit.name)
                                .font(.caption)
                                .strikethrough(item.isCompleted)
                                .foregroundColor(item.isCompleted ? .secondary : .primary)
                            
                            Spacer()
                            
                            if item.habit.currentStreak > 0 {
                                HStack(spacing: 2) {
                                    Text("🔥")
                                        .font(.caption2)
                                    Text("\(item.habit.currentStreak)")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                    
                    if todaysHabits.count > 5 {
                        Text("+\(todaysHabits.count - 5) more")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Quick Stats
            HStack(spacing: 20) {
                VStack {
                    Text("\(totalCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Total")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(completedCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Done")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(Int(completionRate * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Rate")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}