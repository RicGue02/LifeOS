//
//  MotivationWidget.swift
//  Life OS
//
//  Created by Assistant on 22/7/25.
//

import SwiftUI

struct Quote {
    let text: String
    let author: String
    let category: QuoteCategory
}

enum QuoteCategory {
    case health, wealth, wisdom, general
    
    var color: Color {
        switch self {
        case .health: return .red
        case .wealth: return .yellow
        case .wisdom: return .blue
        case .general: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .wealth: return "dollarsign.circle.fill"
        case .wisdom: return "brain"
        case .general: return "sparkles"
        }
    }
}

struct MotivationWidget: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var currentQuote: Quote
    
    private let quotes: [Quote] = [
        // Health quotes
        Quote(text: "Take care of your body. It's the only place you have to live.", author: "Jim Rohn", category: .health),
        Quote(text: "Health is not about the weight you lose, but about the life you gain.", author: "Josh Billings", category: .health),
        Quote(text: "A healthy outside starts from the inside.", author: "Robert Urich", category: .health),
        
        // Wealth quotes
        Quote(text: "The habit of saving is itself an education.", author: "George S. Clason", category: .wealth),
        Quote(text: "Wealth consists not in having great possessions, but in having few wants.", author: "Epictetus", category: .wealth),
        Quote(text: "Money is only a tool. It will take you wherever you wish.", author: "Ayn Rand", category: .wealth),
        
        // Wisdom quotes
        Quote(text: "The only true wisdom is in knowing you know nothing.", author: "Socrates", category: .wisdom),
        Quote(text: "Knowledge speaks, but wisdom listens.", author: "Jimi Hendrix", category: .wisdom),
        Quote(text: "The journey of a thousand miles begins with one step.", author: "Lao Tzu", category: .wisdom),
        
        // General motivation
        Quote(text: "Your future is created by what you do today, not tomorrow.", author: "Robert Kiyosaki", category: .general),
        Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain", category: .general),
        Quote(text: "Success is the sum of small efforts repeated day in and day out.", author: "Robert Collier", category: .general)
    ]
    
    init() {
        _currentQuote = State(initialValue: quotes.randomElement()!)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<12:
            return "Good morning! ☀️"
        case 12..<18:
            return "Good afternoon! 🌤️"
        default:
            return "Good evening! 🌙"
        }
    }
    
    private func selectQuote() -> Quote {
        let character = dataManager.characterStore.character
        let dimensions = character.dimensions
        
        // Map dimensions to quote categories
        let stats = [
            (dimensions.health.score, QuoteCategory.health),
            (dimensions.wealth.score, QuoteCategory.wealth),
            (dimensions.personal.score, QuoteCategory.wisdom)  // Map personal growth to wisdom
        ]
        
        // Find the lowest stat
        if let lowestStat = stats.min(by: { $0.0 < $1.0 }), lowestStat.0 < 80 {
            // Get quotes for the category that needs improvement
            let categoryQuotes = quotes.filter { $0.category == lowestStat.1 }
            return categoryQuotes.randomElement() ?? quotes.randomElement()!
        }
        
        // If all stats are high, return general motivation
        return quotes.filter { $0.category == .general }.randomElement() ?? quotes.randomElement()!
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with greeting
            HStack {
                Image(systemName: currentQuote.category.icon)
                    .foregroundColor(currentQuote.category.color)
                    .font(.title3)
                
                Text(greeting)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            // Quote
            VStack(alignment: .leading, spacing: 8) {
                Text("\"\(currentQuote.text)\"")
                    .font(.body)
                    .italic()
                    .foregroundColor(.primary.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("— \(currentQuote.author)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Character Level Badge
            HStack {
                Image(systemName: "star.circle.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
                
                Text("Level \(dataManager.characterStore.character.level) • \(dataManager.characterStore.character.experience) XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    currentQuote.category.color.opacity(0.1),
                    currentQuote.category.color.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .onAppear {
            currentQuote = selectQuote()
        }
    }
}