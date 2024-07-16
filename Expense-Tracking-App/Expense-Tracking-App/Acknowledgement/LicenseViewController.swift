//
//  LicenseViewController.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 5/6/2024.
//

import UIKit

class LicenseViewController: UIViewController {
    
    let firebaseLicense = """

    This app leverages Firebase, a comprehensive mobile and web application development platform developed by Google. It utilizes the following Firebase services:

    Firebase Authentication: Provides secure and robust user authentication, enabling users to create accounts and log in safely. (Documentation: https://firebase.google.com/docs/auth)

    Firestore: Offers a scalable, real-time NoSQL database for storing and synchronizing user data, including expenses, income, savings, and other financial information. (Documentation: https://firebase.google.com/docs/firestore)

    Firebase plays a crucial role in enabling secure user management and providing the foundation for storing and accessing financial data within the app.
"""
    
    let swiftLicense = """

    This app leverages Swift Charts, a powerful data visualization framework provided by Apple as part of SwiftUI. Swift Charts is used to display user data, such as expenses, income, savings, and more, in an intuitive and visually appealing manner.

    SwiftUI Framework Documentation: https://developer.apple.com/documentation/charts
"""
    
    let apiLicense = """
    This app leverages the ExchangeRate-API to accurately convert currencies when calculating and displaying user savings. This ensures that financial information is presented in the user's preferred currency.

    ExchangeRate-API Documentation: https://www.exchangerate-api.com/docs/overview
"""
    
    // MARK: - Properties
    
    @IBOutlet weak var licenseText: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    var library: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let library = library {
            switch library {
            case "Firebase":
                licenseText.text = firebaseLicense
            case "ExchangeRate-API":
                licenseText.text = apiLicense
            default:
                licenseText.text = swiftLicense
            }
            licenseText.textAlignment = .center
            licenseText.font = UIFont.systemFont(ofSize: 12)
            licenseText.textColor = UIColor.darkGray
        }
    }
}


