//
//  AllExpensesTableViewController.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 7/5/2024.
//
// This UITableViewController displays the user's expenses in a structured format,
// grouped by category.

import UIKit

class AllExpensesTableViewController: UITableViewController, DatabaseListener {

    // MARK: - Properties
    
    var currentUserExpenses: [Expense] = []
    var categories: [String] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .users
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController as? FirebaseController
        
        // Set table view data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchData()
        
        self.tableView.sectionHeaderTopPadding = 10
    }

    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = categories[section]
        return currentUserExpenses.filter { $0.category == category }.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
    /// Configures each table view cell with the expense name and amount.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath)
        
        let category = categories[indexPath.section] // Get the category for this section
        let expensesForCategory = currentUserExpenses.filter { $0.category == category } // Filter expenses
        
        let expense = expensesForCategory[indexPath.row]
        
        cell.textLabel?.text = expense.name ?? ""
        if let amount = expense.amount {
            cell.detailTextLabel?.text = "$\(String(format: "%.2f", amount))"
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    // MARK: - Navigation
    
    /// Prepares for a segue to the ExpenseDetailTableViewController.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showExpenseDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow { // Get the index path of the selected row
                let category = categories[indexPath.section]
                let expensesForCategory = currentUserExpenses.filter { $0.category == category }
                let selectedExpense = expensesForCategory[indexPath.row] // Get the selected expense object
                
                // Pass the selected expense to the destination view controller
                let destination = segue.destination as! ExpenseDetailTableViewController
                destination.expense = selectedExpense
            }
        }
    }

    // MARK: - Database Listener
    
    /// Handles changes in the user's expense data in the database.
    func onDataChange(change: DatabaseChange, userExpenses: [Expense], userIncomes: [Income]) {
        currentUserExpenses = userExpenses
        categories = Array(Set(userExpenses.map { $0.category ?? "" })) // Extract unique categories
        tableView.reloadData()
    }

    // MARK: - Data Fetching
    
    /// Fetches the latest user data (expenses) from the database.
    func fetchData() {
        databaseController?.fetchUserData()
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
