//
//  ContactDetailViewController.swift
//  CKContacts
//
//  Created by Steve Lederer on 1/4/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var contact: Contact? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - Setup
    
    func updateViews() {
        if let contact = contact {
            nameTextField.text = contact.name
            phoneNumberTextField.text = contact.phoneNumber
            emailTextField.text = contact.email
            navigationItem.title = "Edit: \(contact.name)"
        } else {
            navigationItem.title = "New Contact"
            nameTextField.text = ""
            phoneNumberTextField.text = ""
            emailTextField.text = ""
        }
    }
    
    // MARK: - Actions
    @IBAction func saveContactButtonTapped(_ sender: UIBarButtonItem) {
        if nameTextField.text == "" {
            presentEmptyNameAlert()
        } else {
            guard let name = nameTextField.text,
                let phoneNumber = phoneNumberTextField.text,
                let email = emailTextField.text else { return }
            
            if let contact = contact {
                ContactController.shared.update(contact: contact, with: name, phoneNumber: phoneNumber, email: email) { (success) in
                    if success {
                        print("✅ Success updating entry for \(contact.name)! 😁")
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        print("❌ Failed to update entry. 😢")
                    }
                }
            } else {
                ContactController.shared.createContact(with: name, phoneNumber: phoneNumber, email: email) { (success) in
                    if success {
                        print("✅ Success adding new entry! 😁")
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        print("❌ Failed to add new entry. 😢")
                    }
                }
            }
        }
    }
    
    func presentEmptyNameAlert() {
        let emptyNameAlertController = UIAlertController(title: "Oops!", message: "Name Field is Required", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        emptyNameAlertController.addAction(okayAction)
        self.present(emptyNameAlertController, animated: true)
    }
    
    // MARK: - TextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
            navigationItem.title = nameTextField.text
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        navigationItem.title = nameTextField.text
    }
    
    
}
