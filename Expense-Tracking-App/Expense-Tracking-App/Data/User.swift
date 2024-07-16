//
//  User.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 1/5/2024.
//
// This file defines a model class for representing a User within the app.

import Foundation
import FirebaseFirestoreSwift


class User: NSObject, Codable {
    
    @DocumentID var id: String?
    var email: String?
    var expenses: [Expense] = []
    var incomes: [Income] = []

}

