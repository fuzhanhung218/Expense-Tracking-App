//
//  DashboardViewController.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 17/4/2024.
//
// This view controller displays a pie chart representing the user's expenses
// over different periods (daily, monthly and yearly). This is also accommodated
// by a table view.

import UIKit
import SwiftUI
import Charts


class DashboardViewController: UIViewController, UITableViewDataSource, DatabaseListener {
    
    // MARK: - Properties
    
    var listenerType: ListenerType = .users
    weak var databaseController: DatabaseProtocol? // Reference to the database controller
    
    var currentUserExpenses: [Expense] = []
    var filteredExpenses: [Expense] = []
    
    @IBOutlet weak var addExpenseButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var timelineFilterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var expensesTableView: UITableView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController as? FirebaseController
        
        setUpViewController()
        setUpPieChart()
        
        expensesTableView.dataSource = self
        expensesTableView.reloadData()
    }
    
    // MARK: - UI Setup
    
    /// Configures the appearance and layout of UI elements in the view controller.
    func setUpViewController() {
        timelineFilterSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        
        timelineFilterSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        addExpenseButton.layer.cornerRadius = 8
        addExpenseButton.layer.borderWidth = 2.0
        addExpenseButton.layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: - Chart Setup
    
    /// Initializes and configures the pie chart to display the user's savings data.
    func setUpPieChart() {
        // Convert the currentUserExpenses into the ExpenseDataStructure format for the PieChartUIView.
        let chartView = UIHostingController(rootView: ChartUIView(data: currentUserExpenses.map { ExpenseDataStructure(category: $0.category ?? "", amount: Float($0.amount ?? 0)) }))
        
        chartView.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(chartView)
        view.addSubview(chartView.view)

        // Define constraints
        NSLayoutConstraint.activate([
            chartView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.0),
            chartView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.0),
            chartView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45.0),
            chartView.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
        chartView.didMove(toParent: self)
    }
    
    // MARK: - Data Fetching

    /// Fetches the latest user data (expenses) from the database and then updates the pie chart.
    func fetchData() {
        databaseController?.fetchUserData()
        updatePieChart()
    }

    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Group filtered expenses by category and summing their amounts
        let groupedExpenses = Dictionary(grouping: filteredExpenses, by: { $0.category ?? "" })
        return groupedExpenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath)
        
        // Create a dictionary where its keys are the unique expense categories and the values associated with each key are array of filtered expenses
        let groupedExpenses = Dictionary(grouping: filteredExpenses, by: { $0.category ?? "" })
            .mapValues { $0.reduce(0) { $0 + ($1.amount ?? 0) } } // Apply reduce function to sum up all the amount of all expenses
        
        // Sorting the categories alphabetically
        let sortedCategories = groupedExpenses.keys.sorted()
        
        // Fetching the category and total amount for the current row
        let category = sortedCategories[indexPath.row]
        let totalAmount = groupedExpenses[category] ?? 0.0
        
        cell.textLabel?.text = category
        cell.detailTextLabel?.text = "$\(String(format: "%.2f", totalAmount))"
        
        return cell
    }

    // MARK: - Navigation

    /// Performs a segue to the "Add Income" view controller.
    @IBAction func addExpense(_ sender: Any) {
        performSegue(withIdentifier: "addTransaction", sender: self)
    }
    
    // MARK: - DatabaseListener
    
    /// Updates the stored user expenses, updates the pie chart and refreshes the table view.
    func onDataChange(change: DatabaseChange, userExpenses: [Expense], userIncomes: [Income]) {
        currentUserExpenses = userExpenses
        updatePieChart()
        expensesTableView.reloadData()
    }
    
    // MARK: - Actions
    
    /// Updates the pie chart to account for the timeline filter selected by the user.
    @IBAction func timelineFilterChanged(_ sender: Any) {
        // Set the font color for the selected segment to black
        timelineFilterSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        
        // Set the font color for non-selected segments to white
        timelineFilterSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        updatePieChart()
    }
    
    // MARK: - Chart Data Update
    
    /// Updates the data in the pie chart to reflect the selected timeline.
    func updatePieChart() {
        switch timelineFilterSegmentedControl.selectedSegmentIndex {
        case 0: // Daily
            filteredExpenses = filterExpensesByDate(expenses: currentUserExpenses, timeframe: .day)
        case 1: // Monthly
            filteredExpenses = filterExpensesByDate(expenses: currentUserExpenses, timeframe: .month)
        case 2: // Yearly
            filteredExpenses = filterExpensesByDate(expenses: currentUserExpenses, timeframe: .year)
        default:
            break
        }
        
        // Group expenses by category and summing up their amount
        let groupedExpenses = Dictionary(grouping: filteredExpenses, by: { $0.category ?? "" })
            .mapValues { $0.reduce(0) { $0 + ($1.amount ?? 0) } }

        // Convert the grouped expenses to ExpenseDataStructure instances for the pie chart
        let data = groupedExpenses.map { ExpenseDataStructure(category: $0.key, amount: Float($0.value)) }

        // Find the first child view controller and update the data property of 'chartView' (i.e. pie chart view) with the transformed data array
        if let chartView = children.first(where: { $0 is UIHostingController<ChartUIView> }) as? UIHostingController<ChartUIView> {
            chartView.rootView.data = data
        }
        
        expensesTableView.reloadData()
    }
    
    // MARK: - Expense Filtering
    
    /// Filters an expense by date based on a specific calendar component (e.g. day, month, year and total)
    func filterExpensesByDate(expenses: [Expense], timeframe: Calendar.Component) -> [Expense] {
        let calendar = Calendar.current
        let currentDate = Date()

        let filteredExpenses = expenses.filter { expense in
            if let expenseDate = expense.date {
                // Calculate the difference between the expense date and current date in terms of the time period
                let components = calendar.dateComponents([timeframe], from: expenseDate, to: currentDate)
                return components.value(for: timeframe) == 0 // This value will be 0 if the expense falls within the desired time period
            }
            return false
        }

        return filteredExpenses
    }
    
    // MARK: - View Lifecycle (continued)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        databaseController?.addListener(listener: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
}
