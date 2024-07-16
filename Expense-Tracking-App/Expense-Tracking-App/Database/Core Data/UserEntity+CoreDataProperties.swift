//
//  UserEntity+CoreDataProperties.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 7/6/2024.
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var name: String?

}

extension UserEntity : Identifiable {

}
