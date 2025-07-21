//
//  CharacterView.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var characterStore = CharacterStore()
    @State private var selectedDimension: DimensionType?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Level and Progress Card
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Level \(characterStore.character.level)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("\(characterStore.character.experience) / \(characterStore.character.experienceForNextLevel) XP")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Overall Score")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(Int(characterStore.character.totalScore))%")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        
                        ProgressView(value: characterStore.character.experienceProgress)
                            .tint(.accentColor)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Hexagon Progress
                    HexagonProgressView(dimensions: characterStore.character.dimensions)
                        .frame(height: 300)
                        .padding(.horizontal, 40)
                    
                    // Dimensions Detail
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Life Dimensions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(characterStore.character.dimensions.allDimensions) { dimension in
                            DimensionRow(
                                dimension: dimension,
                                onTap: {
                                    selectedDimension = DimensionType(rawValue: dimension.name)
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recent Achievements
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Progress")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            AchievementRow(
                                icon: "checkmark.circle.fill",
                                title: "Daily Streak",
                                subtitle: "7 days in a row",
                                points: "+50 XP",
                                color: .green
                            )
                            
                            AchievementRow(
                                icon: "star.fill",
                                title: "Habit Master",
                                subtitle: "Completed all habits today",
                                points: "+30 XP",
                                color: .yellow
                            )
                            
                            AchievementRow(
                                icon: "flag.fill",
                                title: "Task Crusher",
                                subtitle: "10 tasks completed",
                                points: "+100 XP",
                                color: .blue
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Character")
            .sheet(item: $selectedDimension) { dimension in
                DimensionDetailView(
                    dimension: dimension,
                    characterStore: characterStore
                )
            }
        }
        .onAppear {
            updateCharacterScores()
        }
    }
    
    private func updateCharacterScores() {
        // Update health score based on habits
        let healthScore = characterStore.calculateHealthScore(from: dataManager.habitStore.habits)
        characterStore.updateDimensionScore(.health, score: healthScore)
        
        // Update career score based on tasks
        let careerScore = characterStore.calculateCareerScore(
            tasksCompleted: dataManager.taskStore.completedTasks.count,
            totalTasks: dataManager.taskStore.tasks.count
        )
        characterStore.updateDimensionScore(.career, score: careerScore)
    }
}

struct DimensionRow: View {
    let dimension: Dimension
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: dimension.icon)
                    .font(.title2)
                    .foregroundColor(dimension.color)
                    .frame(width: 40)
                
                VStack(alignment: .leading) {
                    Text(dimension.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(dimension.level)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(Int(dimension.score))%")
                        .font(.headline)
                    
                    ProgressView(value: dimension.score / 100)
                        .frame(width: 60)
                        .tint(dimension.color)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AchievementRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let points: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(points)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(6)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// Dimension Detail Sheet
struct DimensionDetailView: View {
    let dimension: DimensionType
    @ObservedObject var characterStore: CharacterStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Placeholder for dimension-specific content
                Text("Detailed view for \(dimension.rawValue)")
                    .font(.headline)
                
                Text("Track and improve your \(dimension.rawValue.lowercased()) score")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle(dimension.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

extension DimensionType: Identifiable {
    var id: String { rawValue }
}