//
//  BarChartUIView.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 8/5/2024.
//
// This SwiftUI View is responsible for displaying a bar chart that visualizes
// the user's savings over various time periods (daily, monthly, yearly, and total).

import SwiftUI
import Charts

/// A data structure representing savings data for the bar chart, including amount and date.
struct SavingsDataStructure: Identifiable, Equatable { // Add Equatable conformance
    var amount: Float
    var date: Date
    var id = UUID()
}

/// A bar chart view for displaying a bar chart of savings data.
struct BarChartUIView: View {
    var data: [SavingsDataStructure] = []
    
    // Define categories for the X-axis
    let categories: [String] = ["Daily", "Monthly", "Yearly", "All"]

    var body: some View {
        VStack(alignment: .leading) {
            
            // Add the title "Savings Overview" at the top
            Text("Savings Overview")
                .font(.system(size: 25, weight: .bold))
                .padding()
            
            // Chart Container
            ZStack {
                Color(UIColor.systemGray6).ignoresSafeArea()

                // Display "no data available" text if data is empty
                if data.isEmpty {
                    Text("No data available")
                } else {
                    Chart {
                        ForEach(data) { savingsData in
                            let barColor: Color = savingsData.amount >= 0 ? .green : .red
                            
                            // Create a bar for each savings data point
                            BarMark(
                                // Set the x value to a specific time period from the array of time periods
                                x: .value("Time Period", categories[data.firstIndex(of: savingsData)!]),
                                // Set the y value to a specific amount from the data
                                y: .value("Amount Saved", savingsData.amount)
                            )
                            // Display the annotation (amount) above each bar
                            .annotation(position: .top) {
                                Text(String(format: "$%.0f", savingsData.amount))
                                    .foregroundColor(Color.gray)
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundStyle(barColor)
                            .cornerRadius(10)
                        }
                    }
                    // Set up the y-axis
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                if let savingsAmount = value.as(Float.self) {
                                    Text("$\(Int(savingsAmount))") // Dollar values on the y-axis.
                                }
                            }
                            AxisGridLine()
                            AxisTick()
                        }
                    }
                    // Set the y-axis label to "Amount Saved in $"
                    .chartYAxisLabel("Amount Saved in $", position: .leading)
                    // Set up the x-axis where desiredCount is the number of values or labels the axis will display
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: data.count))
                    }
                    // Set the x-axis label to "Time Period"
                    .chartXAxisLabel("Time Period", position: .bottom, alignment: .center)
                    .frame(width: 350, height: 300)
                    .padding()
                }
            }
        }
        // Set the background color of the entire view
        .background(Color(UIColor.systemGray6))
        .ignoresSafeArea()
    }
}
