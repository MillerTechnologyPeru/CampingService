//
//  User.swift
//  
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import Foundation

/// User
public struct User: Equatable, Hashable, Codable, Identifiable {
    
    public let id: UUID
    
    public let created: Date
    
    public var email: String
    
    public var firstName: String
    
    public var lastName: String
    
    public let gender: Gender
    
    public var role: Role
    
    public var phoneNumber: String?
    
    public init(
        id: UUID = UUID(),
        email: String,
        firstName: String,
        lastName: String,
        gender: Gender = .male,
        role: Role = .client,
        phoneNumber: String? = nil
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.role = role
        self.phoneNumber = phoneNumber
        self.created = Date()
    }
}

public extension User {
    
    enum Role: Int, Codable, CaseIterable {
        
        case client             = 0
        case campgroundAdmin    = 900
        case admin              = 990
        case superAdmin         = 999
    }
}

public extension User {
    
    enum Gender: String, Codable, CaseIterable {
        
        case male
        case female
    }
}
