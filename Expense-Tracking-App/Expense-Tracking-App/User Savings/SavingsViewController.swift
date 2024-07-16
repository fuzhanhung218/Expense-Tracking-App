//
//  SavingsViewController.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 21/5/2024.
//
// This view controller displays a bar chart representing the user's savings
// over different periods (daily, monthly, yearly, and total) and in different
// currency if needed by the user through the API 'ExchangeRate-API'.

import UIKit
import Foundation
import SwiftUI

/// A data structure representing an expense category and its amount.
struct Savings {
    var period: Date?
    var amount: Float?
}

/// An enum representing the selected time period for savings
enum Period {
    case day
    case month
    case year
    case total
}

/// A data structure representing the response from the exchange rate API
struct ExchangeRateResponse: Codable {
    let result: String
    let documentation: String
    let terms_of_use: String
    let time_last_update_unix: Int
    let time_last_update_utc: String
    let time_next_update_unix: Int
    let time_next_update_utc: String
    let base_code: String
    let conversion_rates: [String: Double]
}

class SavingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, DatabaseListener {
    
    // MARK: - Properties
    
    // Currency names for display
    let currencyNames: [String: String] = [
        "AUD": "Australian Dollar",
        "USD": "US Dollar",
        "EUR": "Euro",
        "HKD": "Hong Kong Dollar",
        "JPY": "Japanese Yen",
        "AED": "Dirham",
        "CNY": "Chinese Renminbi"
    ]
    
    // Currency codes for the picker view
    var currencies = ["AUD", "USD", "EUR", "CNY", "AED", "HKD", "JPY"]
    var selectedCurrencyIndex = 0
    
    @IBOutlet weak var currencyPickerView: UIPickerView!
    @IBOutlet weak var currencyText: UILabel!
    
    var listenerType: ListenerType = .users
    weak var databaseController: DatabaseProtocol?
    var exchangeRateResponse: ExchangeRateResponse?
    
    // Arrays to store user data (expenses, incomes, savings)
    var currentUserExpenses: [Expense] = []
    var currentUserIncomes: [Income] = []
    var currentUserSavings: [Savings] = []

    @IBOutlet weak var addNewIncomeButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController as? FirebaseController
        
        // Set up the currency picker view
        currencyPickerView.delegate = self
        currencyPickerView.dataSource = self
        
        setUpViewController()
        
        // Fetch initial exchange rates and set up the bar chart asynchronously
        Task {
             URLSession.shared.invalidateAndCancel()
             await requestCurrency(for: "AUD")
             setupBarChart()
         }
        
        updateBarChartData()
    }
    
    // MARK: - UI Setup
    
    /// Configures the appearance and layout of UI elements in the view controller.
    func setUpViewController() {
        addNewIncomeButton.layer.cornerRadius = 8
        addNewIncomeButton.layer.borderWidth = 2.0
        addNewIncomeButton.layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Update the selected currency index
        selectedCurrencyIndex = row
        
        // Get the currency code for the selected currency
        let selectedCurrency = currencies[row]
        
        // Fetch new exchange rates asynchronously
        Task {
             URLSession.shared.invalidateAndCancel()
             await requestCurrency(for: selectedCurrency)
         }
        
        updateBarChartData()
    }
    
    // MARK: - Exchange Rate API
    
    /// Asynchronously fetches the latest exchange rates from the API for a given currency code.
    func requestCurrency(for currencyCode: String) async {
        // Construct API Request URL
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "v6.exchangerate-api.com"
        // Set the path (this includes my individual API key and the requested currency code)
        searchURLComponents.path = "/v6/e2e6970f7e93bc3d9d5f13e1/latest/\(currencyCode)"
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            // Make the asynchronous API call using URLSession to fetch data
            let (data, response) =
                try await URLSession.shared.data(for: urlRequest)
            
            // Parse the response data
            let decoder = JSONDecoder()
            
            // Decode the JSON data into an ExchangeRateResponse object
            let exchangeRateResponse = try decoder.decode(ExchangeRateResponse.self, from: data)
            
            // Update the view controller's property with the latest exchange rate data
            self.exchangeRateResponse = exchangeRateResponse
        }
        catch let error {
            print(error)
        }
    }
    
    // MARK: - Chart Setup
    
    /// Initializes and configures the bar chart to display the user's savings data.
    func setupBarChart() {
        // Convert the currentUserSavings into the SavingsDataStructure format for the BarChartUIView.
        let savingsData = currentUserSavings.map { saving -> SavingsDataStructure in
            let date = saving.period ?? Date()
            let amount = saving.amount ?? 0
            return SavingsDataStructure(amount: amount, date: date)
        }
        
        // Set up BarChartUIView
        let chartView = UIHostingController(rootView: BarChartUIView(data: savingsData))
        
        chartView.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(chartView)
        view.addSubview(chartView.view)

        // Define constraints
        NSLayoutConstraint.activate([
            chartView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.0),
            chartView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.0),
            chartView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15.0),
            chartView.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
        chartView.didMove(toParent: self)
        
        updateSavingsLabel()
    }
    
    // MARK: - Exchange Rate Calculation
    
    /// Calculates the exchange rate between two currencies based on the fetched data from the API.
    func getExchangeRate(from baseCurrency: String, to targetCurrency: String) -> Double? {
        if let rates = exchangeRateResponse?.conversion_rates {
            // Calculate conversion rate directly from base to target
            if let targetRate = rates[targetCurrency], let baseRate = rates[baseCurrency] {
                return targetRate / baseRate
            }
        }
        return nil
    }
    
    // MARK: - Chart Data Update
    
    /// Updates the data in the bar chart to reflect the selected currency.
    func updateBarChartData() {
        let selectedCurrencyCode = currencies[selectedCurrencyIndex]

        // Get the exchange rate from AUD (the base currency) to the selected currency
        // Note, for all conversion calculation, it will use AUD as the base currency
        guard let conversionRate = getExchangeRate(from: "AUD", to: selectedCurrencyCode) else {
            print("Error: Missing exchange rate data for \(selectedCurrencyCode).")
            return
        }

        // Convert savings amounts to the selected currency
        let data: [SavingsDataStructure] = currentUserSavings.map { saving in
            let date = saving.period ?? Date()
            let amountInBaseCurrency = saving.amount ?? 0

            // Convert amount to the selected currency using the fetched exchange rate
            let amountInSelectedCurrency = amountInBaseCurrency * Float(conversionRate)

            return SavingsDataStructure(amount: amountInSelectedCurrency, date: date)
        }
        
        // Find the UIHostingController that manages the BarChartUIView
        if let barChartView = children.first(where: { $0 is UIHostingController<BarChartUIView> }) as? UIHostingController<BarChartUIView> {
            // Update the data in the BarChartUIView
            barChartView.rootView.data = data
        } else {
            print("Warning: BarChartUIView not found in child view controllers.")
        }
        
        updateSavingsLabel()
    }
    
    // MARK: - Currency Label Update

    /// Retrieves the full name of a currency based on its code.
    func getCurrencyName(for currencyCode: String) -> String? {
        return currencyNames[currencyCode]
    }
    
    /// Updates the label displaying the user's savings to reflect the currently selected currency.
    func updateSavingsLabel() {
        let selectedCurrencyCode = currencies[selectedCurrencyIndex]
        if let currencyName = getCurrencyName(for: selectedCurrencyCode) {
            currencyText.text = "Your savings in \(currencyName)" // Set the label text with the full currency name
        } else {
            currencyText.text = "Your savings in \(selectedCurrencyCode)" // Set the label text with the currency code
        }
    }
    
    // MARK: - Data Fetching

    /// Fetches the latest user data (expenses and incomes) from the database and then updates the bar chart.
    func fetchData() {
        databaseController?.fetchUserData()
        updateBarChartData()
    }
    
    // MARK: - Navigation

    /// Performs a segue to the "Add Income" view controller.
    @IBAction func addIncome(_ sender: Any) {
        performSegue(withIdentifier: "addIncome", sender: self)
    }
    
    // MARK: - DatabaseListener
    
    /// Updates the stored user expenses and incomes, recalculates savings, and refreshes the bar chart.
    func onDataChange(change: DatabaseChange, userExpenses expenses: [Expense], userIncomes incomes: [Income]) {
        currentUserExpenses = expenses
        currentUserIncomes = incomes
        
        // Recalculate Savings
        calculateSavings()
        
        updateBarChartData()
    }
    
    // MARK: - Savings Calculation
    
    /// Calculates the user's savings for different time periods: daily, monthly, yearly, and total.
    func calculateSavings() {
        let now = Date()
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: now)
        
        // Calculate daily savings (today's income - today's expenses)
        let dailySavings = Savings(
            period: currentDate,
            amount: sumIncome(for: .day, from: currentDate) - sumExpense(for: .day, from: currentDate)
        )
        
        // Calculate monthly savings (last month's income - last month's expenses)
        let monthlySavings = Savings(
            period: calendar.date(byAdding: .month, value: -1, to: currentDate),
            amount: sumIncome(for: .month, from: currentDate) - sumExpense(for: .month, from: currentDate)
        )
        
        // Calculate yearly savings (last year's income - last year's expenses)
        let yearlySavings = Savings(
            period: calendar.date(byAdding: .year, value: -1, to: currentDate),
            amount: sumIncome(for: .year, from: currentDate) - sumExpense(for: .year, from: currentDate)
        )
        
        // Calculate total savings (all income - all expenses)
        let totalSavings = Savings(
            period: currentDate,
            amount: sumIncome(for: .total, from: currentDate) - sumExpense(for: .total, from: currentDate)
        )
        
        // Update the currentUserSavings array with the calculated savings for each period.
        currentUserSavings = [dailySavings, monthlySavings, yearlySavings, totalSavings]
    }
    
    /// Calculates the total income for a given period of time.
    func sumIncome(for period: Period, from date: Date) -> Float {
        return currentUserIncomes.filter { income in
            guard let incomeDate = income.date else {
                return false
            } // Filter out incomes without dates
            return isWithin(period, from: date, to: incomeDate) // Filter based on the period
        }.reduce(0) { $0 + ($1.amount ?? 0) } // Sum up the amounts
        
        // .reduce() function usage reference: https://stackoverflow.com/questions/72424588/what-is-the-reduce-function-doing-in-swift
    }
    
    /// Calculates the total expenses for a given period of time.
    func sumExpense(for period: Period, from date: Date) -> Float {
        return currentUserExpenses.filter { expense in
            guard let expenseDate = expense.date else {
                return false
            } // Filter out expenses without dates
            return isWithin(period, from: date, to: expenseDate) // Filter based on the period
        }.reduce(0) { $0 + ($1.amount ?? 0) } // Sum up the amounts
    }
    
    /// Determines if a given date falls within a specified time period relative to a reference date.
    func isWithin(_ period: Period, from date: Date, to targetDate: Date) -> Bool {
        let calendar = Calendar.current
        switch period {
        case .day:
            // Check if the target date is in the same day as the reference date
            return calendar.isDate(targetDate, inSameDayAs: date)
        case .month:
            // Check if the target date is in the same month and year as the reference date
            return calendar.isDate(targetDate, equalTo: date, toGranularity: .month)
        case .year:
            // Check if the target date is in the same year as the reference date
            return calendar.isDate(targetDate, equalTo: date, toGranularity: .year)
        case .total:
            // For the 'total' period, always return true
            return true
        }
    }
    
    // MARK: - View Lifecycle (continued)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedCurrencyIndex = 0 // Index for "AUD"
        currencyPickerView.selectRow(selectedCurrencyIndex, inComponent: 0, animated: false) // Set default selected row to AUD
        databaseController?.removeListener(listener: self)
    }
}
