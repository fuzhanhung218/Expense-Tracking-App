//
//  Expense.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 30/4/2024.
//
// This file defines a model class for representing an Income.

import UIKit
import FirebaseFirestoreSwift

class Income: NSObject, Codable {
    
    @DocumentID var id: String?
    var amount: Float?
    var date: Date?

}
