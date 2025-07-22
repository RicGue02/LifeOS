//
//  DailyReviewView.swift
//  Life OS
//
//  Created by Assistant on 22/7/25.
//

import SwiftUI

struct DailyReviewView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    let date: Date
    
    @State private var accomplishments = ""
    @State private var challenges = ""
    @State private var lessonsLearned = ""
    @State private var tomorrowsPriorities = ""
    @State private var gratitude = ""
    @State private var moodRating = 3
    @State private var energyRating = 3
    @State private var productivityRating = 3
    
    private var schedule: DailySchedule {
        dataManager.dailyStore.getSchedule(for: date)
    }
    
    private var statistics: DailyStatistics {
        dataManager.dailyStore.getStatistics(for: date)
    }
    
    init(date: Date) {
        self.date = date
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Day Summary Card
                    DaySummaryCard(date: date, statistics: statistics)
                        .padding(.horizontal)
                    
                    // Ratings Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How was your day?")
                            .font(.headline)
                        
                        RatingRow(
                            title: "Mood",
                            icon: "face.smiling",
                            rating: $moodRating,
                            lowLabel: "Bad",
                            highLabel: "Great"
                        )
                        
                        RatingRow(
                            title: "Energy",
                            icon: "bolt.fill",
                            rating: $energyRating,
                            lowLabel: "Low",
                            highLabel: "High"
                        )
                        
                        RatingRow(
                            title: "Productivity",
                            icon: "chart.line.uptrend.xyaxis",
                            rating: $productivityRating,
                            lowLabel: "Low",
                            highLabel: "High"
                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Reflection Questions
                    VStack(spacing: 20) {
                        ReflectionField(
                            title: "What did you accomplish today?",
                            placeholder: "List your wins, big or small...",
                            text: $accomplishments,
                            icon: "checkmark.circle"
                        )
                        
                        ReflectionField(
                            title: "What challenges did you face?",
                            placeholder: "What obstacles came up...",
                            text: $challenges,
                            icon: "exclamationmark.triangle"
                        )
                        
                        ReflectionField(
                            title: "What did you learn?",
                            placeholder: "Insights or lessons from today...",
                            text: $lessonsLearned,
                            icon: "lightbulb"
                        )
                        
                        ReflectionField(
                            title: "What are you grateful for?",
                            placeholder: "Three things you appreciate...",
                            text: $gratitude,
                            icon: "heart"
                        )
                        
                        ReflectionField(
                            title: "Tomorrow's top priorities?",
                            placeholder: "What needs focus tomorrow...",
                            text: $tomorrowsPriorities,
                            icon: "star"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: saveReview) {
                        Label("Complete Review", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Daily Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadExistingReview()
            }
        }
    }
    
    private func loadExistingReview() {
        if let review = schedule.dailyReview {
            accomplishments = review.accomplishments
            challenges = review.challenges
            lessonsLearned = review.lessonsLearned
            tomorrowsPriorities = review.tomorrowsPriorities
            gratitude = review.gratitude
            moodRating = review.moodRating
            energyRating = review.energyRating
            productivityRating = review.productivityRating
        }
    }
    
    private func saveReview() {
        let review = DailyReview(
            date: date,
            accomplishments: accomplishments,
            challenges: challenges,
            lessonsLearned: lessonsLearned,
            tomorrowsPriorities: tomorrowsPriorities,
            gratitude: gratitude,
            moodRating: moodRating,
            energyRating: energyRating,
            productivityRating: productivityRating
        )
        
        dataManager.dailyStore.saveDailyReview(review, for: date)
        
        // Update character based on review
        updateCharacterFromReview()
        
        dismiss()
    }
    
    private func updateCharacterFromReview() {
        // Give XP based on completion and ratings
        let baseXP = 50
        let ratingBonus = (moodRating + energyRating + productivityRating - 9) * 5
        let completionBonus = Int(statistics.completionRate * 50)
        
        let totalXP = baseXP + ratingBonus + completionBonus
        dataManager.characterStore.addExperience(totalXP)
        
        // Update dimensions based on category completion
        let categoryCompletion = calculateCategoryCompletion()
        for (category, rate) in categoryCompletion {
            switch category {
            case .health:
                let newScore = 50 + (rate * 50) // Convert rate to 0-100 scale
                dataManager.characterStore.updateDimensionScore(.health, score: newScore)
            case .work:
                let newScore = 50 + (rate * 50) // Convert rate to 0-100 scale
                dataManager.characterStore.updateDimensionScore(.career, score: newScore)
            case .personal:
                let newScore = 50 + (rate * 50) // Convert rate to 0-100 scale
                dataManager.characterStore.updateDimensionScore(.personal, score: newScore)
            case .social:
                let newScore = 50 + (rate * 50) // Convert rate to 0-100 scale
                dataManager.characterStore.updateDimensionScore(.relationships, score: newScore)
            case .learning:
                let newScore = 50 + (rate * 30) // Convert rate to 0-100 scale with smaller impact
                dataManager.characterStore.updateDimensionScore(.personal, score: newScore)
            default:
                break
            }
        }
    }
    
    private func calculateCategoryCompletion() -> [BlockCategory: Double] {
        var categoryCompletion: [BlockCategory: Double] = [:]
        
        for block in schedule.timeBlocks {
            let rate = block.isCompleted ? 1.0 : 0.0
            categoryCompletion[block.category, default: 0] += rate
        }
        
        // Average the rates
        for (category, total) in categoryCompletion {
            let count = schedule.timeBlocks.filter { $0.category == category }.count
            categoryCompletion[category] = total / Double(count)
        }
        
        return categoryCompletion
    }
}

struct DaySummaryCard: View {
    let date: Date
    let statistics: DailyStatistics
    
    var body: some View {
        VStack(spacing: 16) {
            // Date
            Text(date.formatted(date: .complete, time: .omitted))
                .font(.headline)
            
            // Stats Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                SummaryStatView(
                    title: "Time Blocked",
                    value: String(format: "%.1f hrs", statistics.totalHours),
                    icon: "clock.fill",
                    color: .blue
                )
                
                SummaryStatView(
                    title: "Completed",
                    value: "\(statistics.completedBlocks)/\(statistics.totalBlocks)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                SummaryStatView(
                    title: "Completion",
                    value: "\(Int(statistics.completionRate * 100))%",
                    icon: "chart.pie.fill",
                    color: .orange
                )
                
                SummaryStatView(
                    title: "Focus Time",
                    value: String(format: "%.1f hrs", statistics.completedHours),
                    icon: "target",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SummaryStatView: View {
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
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct RatingRow: View {
    let title: String
    let icon: String
    @Binding var rating: Int
    let lowLabel: String
    let highLabel: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text(lowLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { value in
                        Circle()
                            .fill(value <= rating ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text("\(value)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(value <= rating ? .white : .gray)
                            )
                            .onTapGesture {
                                rating = value
                            }
                    }
                }
                
                Spacer()
                
                Text(highLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ReflectionField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextEditor(text: $text)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    Group {
                        if text.isEmpty {
                            Text(placeholder)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }
}