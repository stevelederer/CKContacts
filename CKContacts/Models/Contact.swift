//
//  Contact.swift
//  CKContacts
//
//  Created by Steve Lederer on 1/4/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation
import CloudKit

struct Keys {
    static let nameKey = "name"
    static let phoneNumberKey = "phoneNumber"
    static let emailKey = "email"
    static let recordKey = "Contact"
}

class Contact {
    
    // MARK: - Properties
    
    var name: String
    var phoneNumber: String?
    var email: String?
    var ckRecordId: CKRecord.ID
    
    // MARK: - Initializers
    
    init(name: String, phoneNumber: String?, email: String?, ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.ckRecordId = ckRecordId
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[Keys.nameKey] as? String,
            let phoneNumber = ckRecord[Keys.phoneNumberKey] as? String,
            let email = ckRecord[Keys.emailKey] as? String else  { return nil }
        
        self.init(name: name, phoneNumber: phoneNumber, email: email, ckRecordId: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(contact: Contact) {
        self.init(recordType: Keys.recordKey, recordID: contact.ckRecordId)
        
        self.setValue(contact.name, forKey: Keys.nameKey)
        self.setValue(contact.phoneNumber, forKey: Keys.phoneNumberKey)
        self.setValue(contact.email, forKey: Keys.emailKey)
    }
}
