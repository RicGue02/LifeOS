//
//  FinanceStore.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class FinanceStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var budget = Budget()
    
    private let userDefaults = UserDefaults.standard
    private let transactionsKey = "com.lifeos.transactions"
    private let budgetKey = "com.lifeos.budget"
    
    init() {
        loadData()
    }
    
    // MARK: - Transaction Management
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveData()
    }
    
    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
            saveData()
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        saveData()
    }
    
    // MARK: - Budget Management
    
    func updateBudget(_ budget: Budget) {
        self.budget = budget
        saveData()
    }
    
    func setCategoryBudget(_ category: TransactionCategory, amount: Double) {
        budget.categoryBudgets[category] = amount
        saveData()
    }
    
    // MARK: - Calculations
    
    var currentBalance: Double {
        transactions.reduce(0) { balance, transaction in
            balance + (transaction.amount * transaction.type.multiplier)
        }
    }
    
    var monthlyIncome: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return transactions
            .filter { transaction in
                transaction.type == .income &&
                transaction.date >= startOfMonth
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    var monthlyExpenses: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return transactions
            .filter { transaction in
                transaction.type == .expense &&
                transaction.date >= startOfMonth
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    func expensesByCategory(for month: Date = Date()) -> [TransactionCategory: Double] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: month)?.start ?? month
        let endOfMonth = calendar.dateInterval(of: .month, for: month)?.end ?? month
        
        var expenses: [TransactionCategory: Double] = [:]
        
        transactions
            .filter { transaction in
                transaction.type == .expense &&
                transaction.date >= startOfMonth &&
                transaction.date < endOfMonth
            }
            .forEach { transaction in
                expenses[transaction.category, default: 0] += transaction.amount
            }
        
        return expenses
    }
    
    func budgetProgress(for category: TransactionCategory) -> Double {
        let spent = expensesByCategory()[category] ?? 0
        let budgeted = budget.categoryBudgets[category] ?? 0
        
        guard budgeted > 0 else { return 0 }
        return min(spent / budgeted, 1.0)
    }
    
    var savingsRate: Double {
        guard monthlyIncome > 0 else { return 0 }
        return (monthlyIncome - monthlyExpenses) / monthlyIncome
    }
    
    // MARK: - Recurring Transactions
    
    func processRecurringTransactions() {
        let now = Date()
        
        for transaction in transactions where transaction.isRecurring {
            guard let period = transaction.recurringPeriod else { continue }
            
            let daysSinceTransaction = Calendar.current.dateComponents([.day], from: transaction.date, to: now).day ?? 0
            
            if daysSinceTransaction >= period.days {
                let newTransaction = Transaction(
                    amount: transaction.amount,
                    description: transaction.description,
                    category: transaction.category,
                    type: transaction.type,
                    date: now,
                    isRecurring: false
                )
                addTransaction(newTransaction)
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        if let transactionsData = try? JSONEncoder().encode(transactions) {
            userDefaults.set(transactionsData, forKey: transactionsKey)
        }
        
        if let budgetData = try? JSONEncoder().encode(budget) {
            userDefaults.set(budgetData, forKey: budgetKey)
        }
    }
    
    private func loadData() {
        if let transactionsData = userDefaults.data(forKey: transactionsKey),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: transactionsData) {
            transactions = decoded
        }
        
        if let budgetData = userDefaults.data(forKey: budgetKey),
           let decoded = try? JSONDecoder().decode(Budget.self, from: budgetData) {
            budget = decoded
        }
        
        processRecurringTransactions()
    }
    
    // MARK: - Sample Data
    
    func addSampleData() {
        let sampleTransactions = [
            Transaction(amount: 3000, description: "Monthly Salary", category: .salary, type: .income, date: Date().addingTimeInterval(-5 * 24 * 60 * 60)),
            Transaction(amount: 1200, description: "Rent", category: .housing, type: .expense, date: Date().addingTimeInterval(-3 * 24 * 60 * 60)),
            Transaction(amount: 150, description: "Groceries", category: .food, type: .expense, date: Date().addingTimeInterval(-2 * 24 * 60 * 60)),
            Transaction(amount: 50, description: "Gas", category: .transport, type: .expense, date: Date().addingTimeInterval(-1 * 24 * 60 * 60)),
            Transaction(amount: 100, description: "Electric Bill", category: .utilities, type: .expense, date: Date(), isRecurring: true, recurringPeriod: .monthly)
        ]
        
        sampleTransactions.forEach { addTransaction($0) }
        
        budget.monthlyIncome = 3000
        budget.categoryBudgets = [
            .housing: 1200,
            .food: 400,
            .transport: 200,
            .utilities: 150,
            .entertainment: 200,
            .shopping: 300
        ]
        budget.savingsGoal = 500
        
        saveData()
    }
}