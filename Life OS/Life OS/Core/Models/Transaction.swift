//
//  Transaction.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import Foundation
import SwiftUI

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID
    var amount: Double
    var description: String
    var category: TransactionCategory
    var type: TransactionType
    var date: Date
    var isRecurring: Bool
    var recurringPeriod: RecurringPeriod?
    
    init(
        id: UUID = UUID(),
        amount: Double,
        description: String,
        category: TransactionCategory,
        type: TransactionType,
        date: Date = Date(),
        isRecurring: Bool = false,
        recurringPeriod: RecurringPeriod? = nil
    ) {
        self.id = id
        self.amount = amount
        self.description = description
        self.category = category
        self.type = type
        self.date = date
        self.isRecurring = isRecurring
        self.recurringPeriod = recurringPeriod
    }
}

enum TransactionType: String, Codable, CaseIterable {
    case income = "Income"
    case expense = "Expense"
    
    var multiplier: Double {
        switch self {
        case .income: return 1
        case .expense: return -1
        }
    }
    
    var color: Color {
        switch self {
        case .income: return .green
        case .expense: return .red
        }
    }
}

enum TransactionCategory: String, Codable, CaseIterable {
    // Income categories
    case salary = "Salary"
    case freelance = "Freelance"
    case investment = "Investment"
    case gift = "Gift"
    case other = "Other"
    
    // Expense categories
    case food = "Food"
    case transport = "Transport"
    case housing = "Housing"
    case utilities = "Utilities"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case health = "Health"
    case education = "Education"
    case bills = "Bills"
    
    var icon: String {
        switch self {
        case .salary: return "briefcase.fill"
        case .freelance: return "laptopcomputer"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .gift: return "gift.fill"
        case .other: return "ellipsis.circle.fill"
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .housing: return "house.fill"
        case .utilities: return "bolt.fill"
        case .entertainment: return "tv.fill"
        case .shopping: return "cart.fill"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        case .bills: return "doc.text.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .salary, .freelance, .investment, .gift: return .green
        case .food: return .orange
        case .transport: return .blue
        case .housing: return .purple
        case .utilities: return .yellow
        case .entertainment: return .pink
        case .shopping: return .indigo
        case .health: return .red
        case .education: return .cyan
        case .bills: return .gray
        case .other: return .secondary
        }
    }
    
    static var incomeCategories: [TransactionCategory] {
        [.salary, .freelance, .investment, .gift, .other]
    }
    
    static var expenseCategories: [TransactionCategory] {
        [.food, .transport, .housing, .utilities, .entertainment, .shopping, .health, .education, .bills, .other]
    }
}

enum RecurringPeriod: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Biweekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var days: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .biweekly: return 14
        case .monthly: return 30
        case .yearly: return 365
        }
    }
}

struct Budget: Codable {
    var monthlyIncome: Double
    var categoryBudgets: [TransactionCategory: Double]
    var savingsGoal: Double
    
    init() {
        self.monthlyIncome = 0
        self.categoryBudgets = [:]
        self.savingsGoal = 0
    }
    
    var totalBudget: Double {
        categoryBudgets.values.reduce(0, +)
    }
    
    var remainingBudget: Double {
        monthlyIncome - totalBudget
    }
}