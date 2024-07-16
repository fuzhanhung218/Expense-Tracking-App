//
//  AddTransactionViewController.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 23/4/2024.
//
// This class is responsible for managing the view where users can add new expense entries.

import UIKit

class AddTransactionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    
    @IBOutlet weak var expenseNameTextView: UITextField!
    @IBOutlet weak var amountTextView: UITextField!
    @IBOutlet weak var categoryTextView: UITextField!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var doneToolBar: UIToolbar!
    @IBOutlet weak var addExpenseButton: UIButton!
    
    weak var databaseController: DatabaseProtocol? // Reference to the database controller
    
    // Expense categories for the picker view
    let expenseCategories = ["Select a category","Rent/Mortgage", "Food", "Groceries", "Transportation",
                             "Healthcare","Utilities", "Entertainment", "Insurance",
                             "Accessories", "Investments", "Subscriptions", "Travel", "Other"]
    var selectedCategory: String?
    
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
        // Set up category picker view
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        
        // Embedding category picker view into the category text field
        categoryTextView.inputView = categoryPickerView
        categoryTextView.inputAccessoryView = doneToolBar
        
        // Set default value for category text field and selected category
        selectedCategory = expenseCategories[0]
        categoryTextView.text = selectedCategory
        
        // Remove from view first so that it only pops up when the category text field is tapped
        categoryPickerView.removeFromSuperview()
        doneToolBar.removeFromSuperview()
        
        // Add bottom border to the expense name text field
        let expenseNameBottomBorder = CALayer()
        expenseNameBottomBorder.frame = CGRect(x: 0, y: expenseNameTextView.frame.size.height - 1, width: expenseNameTextView.frame.size.width, height: 1)
        expenseNameBottomBorder.backgroundColor = UIColor.black.cgColor
        expenseNameTextView.layer.addSublayer(expenseNameBottomBorder)
        expenseNameTextView.borderStyle = .none
        
        // Add bottom border to the amount text field
        let amountBottomBorder = CALayer()
        amountBottomBorder.frame = CGRect(x: 0, y: amountTextView.frame.size.height - 1, width: amountTextView.frame.size.width, height: 1)
        amountBottomBorder.backgroundColor = UIColor.black.cgColor
        amountTextView.layer.addSublayer(amountBottomBorder)
        amountTextView.borderStyle = .none
        
        // Add bottom border to the category text field
        let categoryBottomBorder = CALayer()
        categoryBottomBorder.frame = CGRect(x: 0, y: categoryTextView.frame.size.height - 1, width: categoryTextView.frame.size.width, height: 1)
        categoryBottomBorder.backgroundColor = UIColor.black.cgColor
        categoryTextView.layer.addSublayer(categoryBottomBorder)
        categoryTextView.borderStyle = .none
        
        // Change the placeholder color of the text fields to black
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        expenseNameTextView.attributedPlaceholder = NSAttributedString(string: "Name*", attributes: placeholderAttributes)
        amountTextView.attributedPlaceholder = NSAttributedString(string: "Amount*", attributes: placeholderAttributes)
        categoryTextView.attributedPlaceholder = NSAttributedString(string: "Category*", attributes: placeholderAttributes)
        
        // Style the "Add Expense" button
        addExpenseButton.layer.cornerRadius = 8
        addExpenseButton.layer.borderWidth = 2.0
        addExpenseButton.layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: - Actions
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Check if the text field is the categoryTextView
        if textField == categoryTextView {
            // Add a target to categoryTextView that triggers the textFieldTapped method when editing begin
            categoryTextView.addTarget(self, action: #selector(textFieldTapped), for: .editingDidBegin)
        }
        return true // Allow the text field to become the first responder
    }
    
    /// Toggles the visibility of the category picker view and the 'done' toolbar when the category text field is tapped.
    @objc func textFieldTapped() {
        view.addSubview(categoryPickerView)
        view.addSubview(doneToolBar)
    }
    
    /// Hides the category picker view and the'done' toolbar when the 'done' is tapped.
    @IBAction func doneButtonTapped(_ sender: Any) {
        categoryPickerView.removeFromSuperview()
        doneToolBar.removeFromSuperview()
        categoryTextView.resignFirstResponder()

        // Remove the target
        categoryTextView.removeTarget(self, action: #selector(textFieldTapped), for: .editingDidBegin)
    }
    
    /// Validates the expense name and amount, creates a new expense entry and adds the expense to the user's database.
    @IBAction func addTransaction(_ sender: Any) {
        guard let name = expenseNameTextView.text, let amountText = amountTextView.text, let amount = Float(amountText), let category = selectedCategory else {
            displayMessage(title: "Error", message: "Invalid expense details.")
            return
        }
        
        let selectedDate = datePickerView.date
        
        if let newExpense = databaseController?.addExpense(name: name, category: category, amount: amount, date: selectedDate) {
            databaseController?.addExpenseToUser(expense: newExpense)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UIPickerViewDataSource & UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return expenseCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = expenseCategories[row]
        categoryTextView.text = selectedCategory
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return expenseCategories.count
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
