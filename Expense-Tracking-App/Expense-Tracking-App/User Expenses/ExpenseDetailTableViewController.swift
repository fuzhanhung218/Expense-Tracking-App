//
//  ExpenseDetailTableViewController.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 14/5/2024.
//
// This UITableViewController displays the details of a single expense.

import UIKit

class ExpenseDetailTableViewController: UITableViewController {

    // MARK: - Properties
    
    var expense: Expense?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if an expense object was passed to the view controller.
        guard let expense = expense else {
            displayMessage(title: "Error", message: "Expense does not exist.")
            return
        }
        
        self.tableView.sectionHeaderTopPadding = 10
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Expense Detail"
    }
    
    /// Configures each cell in the table view to display the corresponding expense detail.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseName", for: indexPath)
            cell.textLabel?.text = "Name: \(expense?.name ?? "")"
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCategory", for: indexPath)
            cell.textLabel?.text = "Category: \(expense?.category ?? "")"
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseAmount", for: indexPath)
            if let amount = expense?.amount {
                cell.textLabel?.text = "Amount: $\(String(format: "%.2f", amount))"
            } else {
                cell.textLabel?.text = "Amount: N/A"
            }
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseDate", for: indexPath)
            if let expenseDate = expense?.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy 'at' hh:mm a" // Example format: 01/01/2024 at 03:45 PM
                let dateString = dateFormatter.string(from: expenseDate)
                cell.textLabel?.text = "Date of Transaction: \(dateString)"
            } else {
                cell.textLabel?.text = "Date of Transaction: N/A"
            }

        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    // MARK: - Helper Methods
    
    /// Displays an alert message to the user.
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
         preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
         handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
