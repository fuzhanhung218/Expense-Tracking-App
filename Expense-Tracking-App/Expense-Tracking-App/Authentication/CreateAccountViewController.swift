//
//  CreateAccountViewController.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 16/4/2024.
//
// This view controller handles the creation of new user accounts within the application. It interacts with Firebase for authentication and provides a user interface for inputting email and password information.

import UIKit
import CoreData

class CreateAccountViewController: UIViewController, AuthenticationListener {

    // MARK: - Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var firebaseController: FirebaseController? // Reference to the firebase controller
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        firebaseController = appDelegate?.databaseController as? FirebaseController
        firebaseController?.authListener = self
        
        setUpViewController()
    }
    
    // MARK: - UI Setup
    
    /// Configures the appearance and layout of UI elements in the view controller.
    func setUpViewController() {
        
        // Set up bottom border for email text field
        let emailBottomBorder = CALayer()
        emailBottomBorder.frame = CGRect(x: 0, y: emailTextField.frame.size.height - 1, width: emailTextField.frame.size.width, height: 1)
        emailBottomBorder.backgroundColor = UIColor.black.cgColor
        emailTextField.layer.addSublayer(emailBottomBorder)
        emailTextField.borderStyle = .none
        
        // Set up bottom border for password text field
        let passwordBottomBorder = CALayer()
        passwordBottomBorder.frame = CGRect(x: 0, y: passwordTextField.frame.size.height - 1, width: passwordTextField.frame.size.width, height: 1)
        passwordBottomBorder.backgroundColor = UIColor.black.cgColor
        passwordTextField.layer.addSublayer(passwordBottomBorder)
        passwordTextField.borderStyle = .none
        
        // Set up bottom border for confirm password text field
        let confirmPasswordBottomBorder = CALayer()
        confirmPasswordBottomBorder.frame = CGRect(x: 0, y: passwordTextField.frame.size.height - 1, width: passwordTextField.frame.size.width , height: 1)
        confirmPasswordBottomBorder.backgroundColor = UIColor.black.cgColor
        confirmPasswordTextField.layer.addSublayer(confirmPasswordBottomBorder)
        confirmPasswordTextField.borderStyle = .none
        
        // Change the placeholder color of the text fields to black
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email*", attributes: placeholderAttributes)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password*", attributes: placeholderAttributes)
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Confirm Password*", attributes: placeholderAttributes)
        
        // Style the "Sign Up" button
        signUpButton.layer.cornerRadius = 8
        signUpButton.layer.borderWidth = 2.0
        signUpButton.layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: - Firebase Sign Up
    
    /// Allows user to sign up an account through firebase
    @IBAction func signUpAccount(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty, password == confirmPasswordTextField.text else {
            displayMessage(title: "Error", message: "Passwords do not match or email/password is empty")
            return
        }
        
        // Change "Sign Up" button appearance to indicate a click
        signUpButton.backgroundColor = .black
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.backgroundColor = .white
        
        firebaseController?.createAccount(email: email, password: password)
    }
    
    // MARK: - Authentication Listener Methods
    
    func onSignUpSuccess() {
        performSegue(withIdentifier: "signUpSuccess", sender: self)
        displayMessage(title: "Thank you", message: "Sign Up Successful")
    }
    
    func onSignInSuccess() {
        
    }
    
    func onAuthError(error: any Error) {
        displayMessage(title: "Error", message: error.localizedDescription)
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
