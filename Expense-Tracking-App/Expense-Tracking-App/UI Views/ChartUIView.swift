//
//  ChartUIView.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 30/4/2024.
//
// This SwiftUI View is responsible for displaying a pie chart representing the user's expenses.

import SwiftUI
import Charts

/// A data structure representing an expense category and its amount.
struct ExpenseDataStructure: Identifiable {
    var category: String
    var amount: Float
    var id = UUID()
}

/// A Pie Chart view for displaying a pie chart of expenses.
struct ChartUIView: View {
    
    /// The data array containing ExpenseDataStructure objects.
    var data: [ExpenseDataStructure] = []
    
    var body: some View {
        ZStack {
            
            // Background color
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            // Display loading text if data is empty
            if data.isEmpty {
                Text("Loading Data...")
            } else {
                // Populating the Pie Chart with data
                Chart(data) { expenseData in
                    // Create a sector in the pie chart for each expense category
                    SectorMark(angle: .value("amount", expenseData.amount), // Sector angle based on amount
                               innerRadius: .ratio(0.618), // Inner radius of the sector
                               angularInset: 1 // Angular inset of the sector
                    )
                    // Set the foreground color of the sector based on the expense category
                    .foregroundStyle(by: .value("category", expenseData.category))
                    .cornerRadius(5)
                }
                .padding()
                .frame(width: 300, height: 300)
            }
        }
    }
}
