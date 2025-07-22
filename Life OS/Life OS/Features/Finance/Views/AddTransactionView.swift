//
//  AddTransactionView.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var financeStore: FinanceStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = ""
    @State private var description = ""
    @State private var type: TransactionType = .expense
    @State private var category: TransactionCategory = .other
    @State private var date = Date()
    @State private var isRecurring = false
    @State private var recurringPeriod: RecurringPeriod = .monthly
    
    private var availableCategories: [TransactionCategory] {
        type == .income ? TransactionCategory.incomeCategories : TransactionCategory.expenseCategories
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Details") {
                    HStack {
                        Text("$")
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    TextField("Description", text: $description)
                    
                    Picker("Type", selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: type) { _, _ in
                        // Reset category when type changes
                        category = type == .income ? .salary : .other
                    }
                }
                
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(availableCategories, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Recurring") {
                    Toggle("Recurring Transaction", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Repeat", selection: $recurringPeriod) {
                            ForEach(RecurringPeriod.allCases, id: \.self) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                    }
                }
                
                if !financeStore.transactions.isEmpty {
                    Section {
                        Button("Add Sample Data") {
                            financeStore.addSampleData()
                            dismiss()
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        
        let transaction = Transaction(
            amount: amountValue,
            description: description,
            category: category,
            type: type,
            date: date,
            isRecurring: isRecurring,
            recurringPeriod: isRecurring ? recurringPeriod : nil
        )
        
        financeStore.addTransaction(transaction)
        dismiss()
    }
}