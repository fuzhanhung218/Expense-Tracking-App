//
//  DatabaseProtocol.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 16/4/2024.
//
// This file defines a set of protocols that outline the expected behavior and functionalities for interacting with the application's database and handling authentication events.

import Foundation
import FirebaseAuth

// DatabaseChange Enum
enum DatabaseChange {
    case add
    case remove
    case update
}

// ListenerType Enum
enum ListenerType {
    case users
    case all
}

// DatabaseListener Protocol
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    // Method to be called when there are changes in the user's data or their expenses and incomes.
    func onDataChange(change: DatabaseChange, userExpenses: [Expense], userIncomes: [Income])
}

// AuthenticationListener Protocol
protocol AuthenticationListener: AnyObject {
    func onSignUpSuccess()
    func onSignInSuccess()
    func onAuthError(error: Error)
}

// DatabaseProtocol Protocol
protocol DatabaseProtocol: AnyObject {
    // Authentication Methods
    func createAccount(email: String, password: String)
    func signInAccount(email: String, password: String)

    // User Management Methods
    func addUser(id: String, email: String)
    func removeUser(user: User)
    
    // Data Manipulation Methods
    func addExpense(name: String, category: String, amount: Float, date: Date) -> Expense
    func addIncome(amount: Float, date: Date) -> Income
    func addExpenseToUser(expense: Expense) -> Bool
    func addIncomeToUser(income: Income) -> Bool
    
    // Listener Management Methods
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    // Fetch Methods
    func fetchUserData()

    // Default User Property
    var defaultUser: User {get}
}
