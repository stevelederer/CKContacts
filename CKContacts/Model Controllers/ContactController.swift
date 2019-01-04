//
//  ContactController.swift
//  CKContacts
//
//  Created by Steve Lederer on 1/4/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation
import CloudKit

class ContactController {
    
    // MARK: - Properties
    
    static let shared = ContactController() // Shared Instance
    
    var contacts: [Contact] = [] // Source of Truth
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    // MARK: - CRUD Functions
    
    // Create
    func createContact(with name: String, phoneNumber: String, email: String, completion: @escaping (Bool) -> ()) {
        let newContact = Contact(name: name, phoneNumber: phoneNumber, email: email)
        let contactRecord = CKRecord(contact: newContact)
        
        privateDB.save(contactRecord) { (record, error) in
            if let error = error {
                print("❌ There was an error saving new contact in \(#function) ; \(error.localizedDescription) ❌")
                completion(false)
                return
            }
            
            guard let record = record,
                let contact = Contact(ckRecord: record) else { completion(false) ; return }
            self.contacts.append(contact)
            self.contacts.sort(by: {$0.name < $1.name})
            completion(true)
        }
    }
    
    // Fetch
    func fetchAllContacts(completion: @escaping (Bool) -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Keys.recordKey, predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("❌ There was an error fetching contacts in \(#function) ; \(error.localizedDescription) ❌")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false) ; return }
            let fetchedContacts = records.compactMap{ Contact(ckRecord: $0) }
            self.contacts = fetchedContacts
            self.contacts.sort(by: {$0.name < $1.name})
            completion(true)
        }
    }
    
    // Update
    func update(contact: Contact, with name: String, phoneNumber: String, email: String, completion: @escaping (Bool) -> ()) {
        contact.name = name
        contact.phoneNumber = phoneNumber
        contact.email = email
        
        privateDB.fetch(withRecordID: contact.ckRecordId) { (record, error) in
            if let error = error {
                print("❌ There was an error fetching the contact to be updated in: \(#function) ; \(error.localizedDescription) ❌")
                completion(false)
                return
            }
            
            guard let record = record else { completion(false) ; return }
            record[Keys.nameKey] = name
            record[Keys.phoneNumberKey] = phoneNumber
            record[Keys.emailKey] = email
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
                completion(true)
            }
            self.privateDB.add(operation)
        }
    }
    
    // Delete
    func delete(contact: Contact, completion: @escaping (Bool) -> ()) {
        privateDB.delete(withRecordID: contact.ckRecordId) { (_, error) in
            if let error = error {
                print("❌ There was an error deleting \(contact.name) in \(#function) ; \(error.localizedDescription) ❌")
                completion(false)
                return
            }
            completion(true)
        }
    }
}
