//
//  FirebaseController.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 16/4/2024.
//
// This class is responsible for handling all interactions with Firebase:
// - Authentication (creating accounts, signing in)
// - Database operations (adding/removing users, expenses, incomes)
//
// Collection          Subcollection          Document
// ------------------------------------------------------
// users                 auto-ID              email: String
//                                            expenses: array of "income"
//                                            incomes: array of "expense"
// ------------------------------------------------------
// income                auto-ID              amount: number
//                                            date: Date
// ------------------------------------------------------
// expense               auto-ID              amount: number
//                                            category: String
//                                            name: String
//                                            date: Date

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var authListener: AuthenticationListener?
    var defaultUser: User // A template user for initialisation
    
    // Firebase References:
    var authController: Auth
    var database: Firestore
    var currentUser: FirebaseAuth.User? // Currently signed-in user
    
    // Collection References:
    var usersRef: CollectionReference?
    var expensesRef: CollectionReference?
    var expenseRef: CollectionReference?
    var incomesRef: CollectionReference?
    var incomeRef: CollectionReference?
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        defaultUser = User()
        
        // Initialise collection references
        usersRef = database.collection("users")
        expensesRef = database.collection("expenses")
        expenseRef = database.collection("expense")
        incomesRef = database.collection("incomes")
        incomeRef = database.collection("income")

        super.init()
    }
    
    // MARK: - Listener Methods
    
    /// Adds a listener to the multicast delegate.
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .users || listener.listenerType == .all {
            listener.onDataChange(change: .update, userExpenses: defaultUser.expenses, userIncomes: defaultUser.incomes)
        }
    }
    
    /// Removes a listener from the multicast delegate.
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // MARK: - Authentication Methods
    
    /// Creates a new account with the specified email and password.
    func createAccount(email: String, password: String) {
        authController.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.authListener?.onAuthError(error: error)
                print("Create Account Error: \(error.localizedDescription)")
            } else {
                self.authListener?.onSignUpSuccess()
                if let authResult = authResult {
                    self.addUser(id: authResult.user.uid, email: email)
                    // Immediately sign in the newly created user
                    self.signInAccount(email: email, password: password)
                }
                print("Account created successfully for email: \(email)")
            }
        }
    }

    /// Signs in to an account with the specified email and password.
    func signInAccount(email: String, password: String) {
        authController.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.authListener?.onAuthError(error: error)
                print("Sign In Error: \(error.localizedDescription)")
            } else {
                self.authListener?.onSignInSuccess()
                if let user = self.authController.currentUser {
                    self.currentUser = user
                    self.setupUserListener()
                    print("Signed in successfully for email: \(email)")
                }
            }
        }
    }
    
    /// Adds a new user to the Firestore database.
    func addUser(id: String, email: String){
        let user = defaultUser
        user.email = email
        user.id = id
        
        // Use the UID as the document ID when adding the user document to Firestore
        usersRef?.document(user.id!).setData(["email": email, "expenses": []]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            }
        }
    }
    
    /// Removes a user from the Firestore database
    func removeUser(user: User) {
        if let userID = user.id {
            usersRef?.document(userID).delete() { error in
                if let error = error {
                    print("Error removing document: \(error)")
                }
            }
        }
    }
    
    // MARK: - Database Methods
    
    /// Adds a new expense to the Firestore database.
    func addExpense(name: String, category: String, amount: Float, date: Date) -> Expense {
        let expense = Expense()
        expense.name = name
        expense.category = category
        expense.amount = amount
        expense.date = date
        
        do {
            if let expenseRef = try expenseRef?.addDocument(from: expense) {
                expense.id = expenseRef.documentID
            }
        } catch {
            print("Failed to serialize expense")
        }
        
        return expense
    }
    
    /// Adds a new income to the Firestore database.
    func addIncome(amount: Float, date: Date) -> Income {
        let income = Income()
        income.amount = amount
        income.date = date
        
        do {
            if let incomeRef = try incomeRef?.addDocument(from: income) {
                income.id = incomeRef.documentID
            }
        } catch {
            print("Failed to serialize income")
        }
        
        return income
    }
    
    /// Adds an expense to the current user's list of expenses in Firestore.
    func addExpenseToUser(expense: Expense) -> Bool {
        guard let expenseID = expense.id else {
            return false
        }

        if let newExpenseRef = expenseRef?.document(expenseID) {
            if let userID = self.currentUser?.uid {
                usersRef?.document(userID).updateData(
                    ["expenses" : FieldValue.arrayUnion([newExpenseRef])]
                ) { error in
                    if let error = error {
                        print("Error updating user expenses: \(error)")
                    } else {
                        print("User expenses updated successfully")
                    }
                }
            }
        }
        
        return true
    }
    
    /// Adds an income to the current user's list of incomes in Firestore
    func addIncomeToUser(income: Income) -> Bool {
        guard let incomeID = income.id else {
            return false
        }
        
        if let newIncomeRef = incomeRef?.document(incomeID) {
            if let userID = self.currentUser?.uid {
                usersRef?.document(userID).updateData(
                    ["incomes" : FieldValue.arrayUnion([newIncomeRef])]
                ) { error in
                    if let error = error {
                        print("Error updating user incomes: \(error)")
                    } else {
                        print("User incomes updated successfully")
                    }
                }
            }
        }
        
        return true
    }

    /// Extracts expense and income references from a user's Firestore document snapshot.
    func parseUserSnapshot(snapshot: DocumentSnapshot) {
        // Extract references to expense and income documents from the user's document
        let expenseReferences = snapshot.data()?["expenses"] as? [DocumentReference] ?? []
        let incomeReferences = snapshot.data()?["incomes"] as? [DocumentReference] ?? []
        
        // Initialise arrays to store the fetched expense and income objects
        var expenses: [Expense] = []
        var incomes: [Income] = []

        // Track the total number of documents to fetch and the number of completed fetches
        let totalFetches = expenseReferences.count + incomeReferences.count
        var completedFetches = 0

        // Closure to check if all fetches are completed
        let checkCompletion = {
            completedFetches += 1
            if completedFetches == totalFetches {
                // All documents fetched
                self.listeners.invoke { (listener) in
                    // Notify all listeners interested in user data of the change
                    if listener.listenerType == ListenerType.users || listener.listenerType == ListenerType.all {
                        listener.onDataChange(change: .update, userExpenses: expenses, userIncomes: incomes)
                    }
                }
            }
        }

        // If there are no documents to fetch, notify listeners immediately
        if totalFetches == 0 {
            self.listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.users || listener.listenerType == ListenerType.all {
                    listener.onDataChange(change: .update, userExpenses: expenses, userIncomes: incomes)
                }
            }
            return
        }

        // Fetch each expense document
        for reference in expenseReferences {
            reference.getDocument { (expenseSnapshot, error) in
                // Check if the document exists and was retrieved successfully
                if let expenseSnapshot = expenseSnapshot, expenseSnapshot.exists {
                    do {
                        // Decode the expense document into an Expense object and add to array
                        if let expense = try expenseSnapshot.data(as: Expense?.self) {
                            expenses.append(expense)
                        }
                    } catch {
                        print("Error decoding expense: \(error)")
                    }
                } else {
                    print("Expense document does not exist or error: \(String(describing: error))")
                }
                // Check if all fetches are complete
                checkCompletion()
            }
        }

        // Fetch each income document
        for reference in incomeReferences {
            reference.getDocument { (incomeSnapshot, error) in
                // Check if the document exists and was retrieved successfully
                if let incomeSnapshot = incomeSnapshot, incomeSnapshot.exists {
                    do {
                        // Decode the income document into an Income object and add to array
                        if let income = try incomeSnapshot.data(as: Income?.self) {
                            incomes.append(income)
                        }
                    } catch {
                        print("Error decoding income: \(error)")
                    }
                } else {
                    print("Income document does not exist or error: \(String(describing: error))")
                }
                // Check if all fetches are complete
                checkCompletion()
            }
        }
    }
    
    /// Fetches a user's  data (expenses and incomes) from Firestore.
    func fetchUserData() {
        // Check if a user is currently signed in
        guard let userID = self.currentUser?.uid else {
            print("Current user ID is nil")
            return
        }

        // Set up the listener for user data changes before fetching the data
        self.listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.users || listener.listenerType == ListenerType.all {
                // Initial call with empty arrays to set up the listener
                listener.onDataChange(change: .update, userExpenses: [], userIncomes: [])
            }
        }

        // Get a reference to the user's document in Firestore using the user ID
        usersRef?.document(userID).getDocument { (documentSnapshot, error) in
            if let document = documentSnapshot, document.exists {
                // If the user document exists, parse it to get the user's expenses and incomes
                self.parseUserSnapshot(snapshot: document)
            } else {
                print("User document does not exist")
            }
        }
    }

    /// Sets up a listener for changes to a user's data in Firestore.
    func setupUserListener() {
        // Check if a user is currently signed in
        guard let currentUserEmail = self.currentUser?.email else {
            print("Current user email is nil")
            return
        }

        // Query Firestore to find the user document with the current user's email
        usersRef?.whereField("email", isEqualTo: currentUserEmail).addSnapshotListener { (querySnapshot, error) in
            // This snapshot listener will be triggered whenever the user document changes
            // (e.g., when expenses or incomes are added or updated)

            guard let querySnapshot = querySnapshot, let userSnapshot = querySnapshot.documents.first else {
                print("Error fetching users: \(String(describing: error))")
                return
            }
            
            // Parse the fetched user document to extract expenses and incomes
            self.parseUserSnapshot(snapshot: userSnapshot)
        }
    }
}
