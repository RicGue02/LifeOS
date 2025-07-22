//
//  FinanceView.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI
import Charts

struct FinanceView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var financeStore = FinanceStore()
    @State private var showingAddTransaction = false
    @State private var selectedPeriod: TimePeriod = .month
    
    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Balance Overview
                    BalanceCard(
                        balance: financeStore.currentBalance,
                        monthlyIncome: financeStore.monthlyIncome,
                        monthlyExpenses: financeStore.monthlyExpenses
                    )
                    .padding(.horizontal)
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        QuickStatCard(
                            title: "Savings Rate",
                            value: "\(Int(financeStore.savingsRate * 100))%",
                            icon: "chart.line.uptrend.xyaxis",
                            color: financeStore.savingsRate > 0.2 ? .green : .orange
                        )
                        
                        QuickStatCard(
                            title: "This Month",
                            value: String(format: "$%.0f", financeStore.monthlyIncome - financeStore.monthlyExpenses),
                            icon: "calendar",
                            color: financeStore.monthlyIncome > financeStore.monthlyExpenses ? .green : .red
                        )
                    }
                    .padding(.horizontal)
                    
                    // Expense Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Expense Breakdown")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ExpenseChart(expenses: financeStore.expensesByCategory())
                            .frame(height: 200)
                            .padding(.horizontal)
                    }
                    
                    // Budget Progress
                    if !financeStore.budget.categoryBudgets.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Budget Progress")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(Array(financeStore.budget.categoryBudgets.keys), id: \.self) { category in
                                BudgetProgressRow(
                                    category: category,
                                    spent: financeStore.expensesByCategory()[category] ?? 0,
                                    budget: financeStore.budget.categoryBudgets[category] ?? 0,
                                    progress: financeStore.budgetProgress(for: category)
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Recent Transactions
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Transactions")
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink("See All") {
                                TransactionListView(financeStore: financeStore)
                            }
                            .font(.caption)
                        }
                        .padding(.horizontal)
                        
                        ForEach(financeStore.transactions.sorted(by: { $0.date > $1.date }).prefix(5)) { transaction in
                            TransactionRow(transaction: transaction)
                                .padding(.horizontal)
                        }
                    }
                    
                    if financeStore.transactions.isEmpty {
                        ContentUnavailableView(
                            "No Transactions",
                            systemImage: "dollarsign.circle",
                            description: Text("Tap + to add your first transaction")
                        )
                        .padding(.top, 50)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Finance")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTransaction = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(financeStore: financeStore)
            }
        }
        .onAppear {
            updateCharacterWealthScore()
        }
    }
    
    private func updateCharacterWealthScore() {
        let wealthScore = dataManager.characterStore.calculateWealthScore(
            monthlyIncome: financeStore.monthlyIncome,
            monthlyExpenses: financeStore.monthlyExpenses
        )
        dataManager.characterStore.updateDimensionScore(.wealth, score: wealthScore)
    }
}

struct BalanceCard: View {
    let balance: Double
    let monthlyIncome: Double
    let monthlyExpenses: Double
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Current Balance")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(String(format: "$%.2f", balance))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(balance >= 0 ? .primary : .red)
            }
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Label(String(format: "$%.0f", monthlyIncome), systemImage: "arrow.down.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    
                    Text("Income")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(spacing: 4) {
                    Label(String(format: "$%.0f", monthlyExpenses), systemImage: "arrow.up.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    
                    Text("Expenses")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct QuickStatCard: View {
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
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ExpenseChart: View {
    let expenses: [TransactionCategory: Double]
    
    var body: some View {
        Chart(Array(expenses), id: \.key) { item in
            BarMark(
                x: .value("Amount", item.value),
                y: .value("Category", item.key.rawValue)
            )
            .foregroundStyle(item.key.color.gradient)
            .annotation(position: .trailing) {
                Text("$\(Int(item.value))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .chartXAxis(.hidden)
    }
}

struct BudgetProgressRow: View {
    let category: TransactionCategory
    let spent: Double
    let budget: Double
    let progress: Double
    
    private var isOverBudget: Bool {
        spent > budget
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Label(category.rawValue, systemImage: category.icon)
                    .font(.subheadline)
                
                Spacer()
                
                Text("$\(Int(spent)) / $\(Int(budget))")
                    .font(.caption)
                    .foregroundColor(isOverBudget ? .red : .secondary)
            }
            
            ProgressView(value: progress)
                .tint(isOverBudget ? .red : category.color)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transaction.category.icon)
                .font(.title2)
                .foregroundColor(transaction.category.color)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(transaction.type == .expense ? "-" : "+")$\(Int(transaction.amount))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.type.color)
                
                if transaction.isRecurring {
                    Label("Recurring", systemImage: "repeat")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}