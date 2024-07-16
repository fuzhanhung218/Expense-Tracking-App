//
//  LogInViewController.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 16/4/2024.
//
// This view controller handles user login functionality within the application. It interacts with Firebase for authentication, providing a user interface for entering email and password credentials.

import UIKit

class LogInViewController: UIViewController, AuthenticationListener {

    // MARK: - Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    
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
        
        // Change the placeholder color of the text fields to black
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email*", attributes: placeholderAttributes)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password*", attributes: placeholderAttributes)
        
        // Style the "Log In" button 
        loginButton.layer.cornerRadius = 8
        loginButton.layer.borderWidth = 2.0
        loginButton.layer.borderColor = UIColor.black.cgColor
    }

    // MARK: - Firebase Sign In
    
    /// Allows user to sign into an existing account through firebase
    @IBAction func signInAccount(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        // Change "Sign In" button appearance to indicate a click
        loginButton.backgroundColor = .black
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .white
        
        firebaseController?.signInAccount(email: email, password: password)
    }
    
    // MARK: - Navigation
    
    @IBAction func signUp(_ sender: Any) {
        performSegue(withIdentifier: "signUp", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAcknowledgement" {
            let destination = segue.destination as! AcknowledgmentTableViewController
        }
    }
    
    // MARK: - Authentication Listener Methods
    
    func onSignUpSuccess() {
        
    }
    
    func onSignInSuccess() {
        performSegue(withIdentifier: "loginSuccessful", sender: self)
    }
    
    // Triggered when authentication fails
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
