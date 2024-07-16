//
//  AddIncomeViewController.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 21/5/2024.
//
// This class is responsible for managing the view where users can add new income entries.

import UIKit

class AddIncomeViewController: UIViewController {
    
    // MARK: - Properties

    @IBOutlet weak var incomeTextView: UITextField!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var addIncomeButton: UIButton!
    
    weak var databaseController: DatabaseProtocol? // Reference to the database controller
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        setUpViewController()
    }
    
    // MARK: - UI Setup
    
    /// Configures the appearance and layout of UI elements in the view controller.
    func setUpViewController() {
        // Add bottom border to the income text field
        let amountBottomBorder = CALayer()
        amountBottomBorder.frame = CGRect(x: 0, y: incomeTextView.frame.size.height - 1, width: incomeTextView.frame.size.width, height: 1)
        amountBottomBorder.backgroundColor = UIColor.black.cgColor
        incomeTextView.layer.addSublayer(amountBottomBorder)
        incomeTextView.borderStyle = .none
        
        // Customize text field placeholder color to black
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        incomeTextView.attributedPlaceholder = NSAttributedString(string: "Amount*", attributes: placeholderAttributes)
        
        // Style the "Add Income" button
        addIncomeButton.layer.cornerRadius = 8
        addIncomeButton.layer.borderWidth = 2.0
        addIncomeButton.layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: - Actions
    
    /// Validates the income amount, creates a new income entry and adds the income to the user's database.
    @IBAction func addIncome(_ sender: Any) {
        guard let incomeAmountText = incomeTextView.text, let incomeAmount = Float(incomeAmountText) else{
            displayMessage(title: "Error", message: "Invalid income details.")
            return
        }

        let selectedDate = datePickerView.date

        // Create a new income object and add it to the user's list of incomes
        if let newIncome = databaseController?.addIncome(amount: incomeAmount, date: selectedDate) {
           databaseController?.addIncomeToUser(income: newIncome)
        }
        
        navigationController?.popViewController(animated: true)
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
