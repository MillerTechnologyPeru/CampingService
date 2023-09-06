//
//  User.swift
//  
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

import Foundation
import CoreModel

/// User
public struct User: Equatable, Hashable, Codable, Identifiable {
    
    public let id: UUID
    
    public let created: Date
    
    public var email: String
    
    public var isEmailVerified: Bool
    
    public var phoneNumber: String?
    
    public var firstName: String
    
    public var lastName: String
    
    public let gender: Gender
    
    public var role: Role
    
    public init(
        id: UUID = UUID(),
        created: Date = Date(),
        email: String,
        isEmailVerified: Bool = false,
        phoneNumber: String? = nil,
        firstName: String,
        lastName: String,
        gender: Gender = .male,
        role: Role = .client
    ) {
        self.id = id
        self.email = email
        self.isEmailVerified = isEmailVerified
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.role = role
        self.phoneNumber = phoneNumber
        self.created = created
    }
    
    public enum CodingKeys: CodingKey {
        case id
        case created
        case email
        case isEmailVerified
        case phoneNumber
        case firstName
        case lastName
        case gender
        case role
    }
}

// MARK: - CoreModel

extension User: Entity {
    
    public static var attributes: [CodingKeys : CoreModel.AttributeType] {
        [
            .created: .date,
            .email: .string,
            .isEmailVerified: .bool,
            .phoneNumber: .string,
            .firstName: .string,
            .lastName: .string,
            .gender: .string,
            .role: .int32
        ]
    }
}

// MARK: - Supporting Types

public extension User {
    
    enum Role: Int, Codable, CaseIterable {
        
        case client             = 0
        case campgroundAdmin    = 900
        case admin              = 990
        case superAdmin         = 999
    }
}

extension User.Role: Comparable {
    
    public static func < (lhs: User.Role, rhs: User.Role) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    public static func > (lhs: User.Role, rhs: User.Role) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
}

public extension User {
    
    enum Gender: String, Codable, CaseIterable {
        
        case male
        case female
    }
}

public extension User {
    
    struct Content: Equatable, Hashable, Codable {
        
        public var phoneNumber: String?
        
        public var firstName: String
        
        public var lastName: String
    }
}
