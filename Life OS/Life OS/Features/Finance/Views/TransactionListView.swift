//
//  TransactionListView.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI

struct TransactionListView: View {
    @ObservedObject var financeStore: FinanceStore
    @State private var searchText = ""
    @State private var filterType: TransactionType?
    @State private var sortOrder: SortOrder = .dateDescending
    
    enum SortOrder: String, CaseIterable {
        case dateDescending = "Newest First"
        case dateAscending = "Oldest First"
        case amountDescending = "Highest Amount"
        case amountAscending = "Lowest Amount"
    }
    
    private var filteredTransactions: [Transaction] {
        var transactions = financeStore.transactions
        
        // Filter by search text
        if !searchText.isEmpty {
            transactions = transactions.filter { transaction in
                transaction.description.localizedCaseInsensitiveContains(searchText) ||
                transaction.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by type
        if let filterType = filterType {
            transactions = transactions.filter { $0.type == filterType }
        }
        
        // Sort
        switch sortOrder {
        case .dateDescending:
            transactions.sort { $0.date > $1.date }
        case .dateAscending:
            transactions.sort { $0.date < $1.date }
        case .amountDescending:
            transactions.sort { $0.amount > $1.amount }
        case .amountAscending:
            transactions.sort { $0.amount < $1.amount }
        }
        
        return transactions
    }
    
    private var groupedTransactions: [(key: Date, value: [Transaction])] {
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        List {
            // Filters
            Section {
                HStack {
                    Menu {
                        Button("All") {
                            filterType = nil
                        }
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Button(type.rawValue) {
                                filterType = type
                            }
                        }
                    } label: {
                        Label(
                            filterType?.rawValue ?? "All Types",
                            systemImage: "line.horizontal.3.decrease.circle"
                        )
                        .font(.caption)
                    }
                    
                    Spacer()
                    
                    Menu {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Button(order.rawValue) {
                                sortOrder = order
                            }
                        }
                    } label: {
                        Label(sortOrder.rawValue, systemImage: "arrow.up.arrow.down")
                            .font(.caption)
                    }
                }
            }
            
            // Grouped Transactions
            ForEach(groupedTransactions, id: \.key) { date, transactions in
                Section {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    financeStore.deleteTransaction(transaction)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    HStack {
                        Text(date.formatted(date: .complete, time: .omitted))
                        
                        Spacer()
                        
                        let dailyTotal = transactions.reduce(0) { total, transaction in
                            total + (transaction.amount * transaction.type.multiplier)
                        }
                        
                        Text(String(format: "$%.2f", dailyTotal))
                            .foregroundColor(dailyTotal >= 0 ? .green : .red)
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("All Transactions")
        .navigationBarTitleDisplayMode(.inline)
    }
}