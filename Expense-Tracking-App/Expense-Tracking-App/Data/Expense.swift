//
//  Expense.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 30/4/2024.
//
// This file defines a model class for representing an Expense.

import UIKit
import FirebaseFirestoreSwift

class Expense: NSObject, Codable {
    
    @DocumentID var id: String?
    var name: String?
    var category: String?
    var amount: Float?
    var date: Date?

}
