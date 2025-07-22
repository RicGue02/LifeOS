//
//  DailyView.swift
//  Life OS
//
//  Created by Assistant on 22/7/25.
//

import SwiftUI

struct DailyView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedDate = Date()
    @State private var showingAddTimeBlock = false
    @State private var showingDailyReview = false
    @State private var selectedTimeBlock: TimeBlock?
    
    private var schedule: DailySchedule {
        dataManager.dailyStore.getSchedule(for: selectedDate)
    }
    
    private var timeSlots: [(hour: Int, blocks: [TimeBlock])] {
        let calendar = Calendar.current
        var slots: [(hour: Int, blocks: [TimeBlock])] = []
        
        // Create slots for each hour from 6 AM to 11 PM
        for hour in 6...23 {
            let hourBlocks = schedule.sortedTimeBlocks.filter { block in
                let blockHour = calendar.component(.hour, from: block.startTime)
                return blockHour == hour
            }
            slots.append((hour: hour, blocks: hourBlocks))
        }
        
        return slots
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date Picker
                DatePickerBar(selectedDate: $selectedDate)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                // Statistics Bar
                DailyStatsBar(schedule: schedule)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                // Time Grid
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(timeSlots, id: \.hour) { slot in
                            TimeSlotRow(
                                hour: slot.hour,
                                blocks: slot.blocks,
                                onBlockTap: { block in
                                    selectedTimeBlock = block
                                },
                                onAddTap: {
                                    // Set default time for new block
                                    showingAddTimeBlock = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Bottom Action Bar
                HStack(spacing: 16) {
                    Button(action: { showingDailyReview = true }) {
                        Label("Daily Review", systemImage: "doc.text")
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!Calendar.current.isDate(selectedDate, inSameDayAs: Date()) ||
                             Calendar.current.component(.hour, from: Date()) < 20)
                    
                    Button(action: { showingAddTimeBlock = true }) {
                        Label("Add Block", systemImage: "plus.circle.fill")
                            .font(.footnote)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Daily")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddTimeBlock) {
                AddTimeBlockView(selectedDate: selectedDate)
            }
            .sheet(isPresented: $showingDailyReview) {
                DailyReviewView(date: selectedDate)
            }
            .sheet(item: $selectedTimeBlock) { block in
                TimeBlockDetailView(
                    timeBlock: block,
                    date: selectedDate
                )
            }
        }
    }
}

struct DatePickerBar: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack {
            Button(action: previousDay) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(selectedDate.formatted(date: .complete, time: .omitted))
                    .font(.headline)
                
                if Calendar.current.isDateInToday(selectedDate) {
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            
            Spacer()
            
            Button(action: nextDay) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func previousDay() {
        withAnimation {
            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func nextDay() {
        withAnimation {
            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        }
    }
}

struct DailyStatsBar: View {
    let schedule: DailySchedule
    
    var body: some View {
        HStack(spacing: 20) {
            StatPill(
                title: "Planned",
                value: "\(schedule.timeBlocks.count)",
                icon: "calendar",
                color: .blue
            )
            
            StatPill(
                title: "Completed",
                value: "\(Int(schedule.completionRate * 100))%",
                icon: "checkmark.circle",
                color: .green
            )
            
            StatPill(
                title: "Time",
                value: formatMinutes(schedule.totalPlannedMinutes),
                icon: "clock",
                color: .orange
            )
        }
        .padding(.vertical, 8)
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}

struct StatPill: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(color.opacity(0.1))
        .cornerRadius(20)
    }
}

struct TimeSlotRow: View {
    let hour: Int
    let blocks: [TimeBlock]
    let onBlockTap: (TimeBlock) -> Void
    let onAddTap: () -> Void
    
    private var hourString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Hour label
            Text(hourString)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
                .padding(.top, 8)
            
            // Time blocks or empty slot
            VStack(alignment: .leading, spacing: 4) {
                if blocks.isEmpty {
                    EmptyTimeSlot(onTap: onAddTap)
                } else {
                    ForEach(blocks) { block in
                        TimeBlockCard(block: block, onTap: { onBlockTap(block) })
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}

struct EmptyTimeSlot: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "plus.circle")
                    .font(.caption)
                Text("Add time block")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TimeBlockCard: View {
    let block: TimeBlock
    let onTap: () -> Void
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Category icon and time
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: block.category.icon)
                            .font(.caption)
                            .foregroundColor(block.category.color)
                        
                        Text(block.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if block.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text(block.timeRangeString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(block.durationString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(block.category.color.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(block.category.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}