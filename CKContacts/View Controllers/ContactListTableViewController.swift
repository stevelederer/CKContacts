//
//  ContactListTableViewController.swift
//  CKContacts
//
//  Created by Steve Lederer on 1/4/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

class ContactListTableViewController: UITableViewController  {
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    func fetchContacts() {
        ContactController.shared.fetchAllContacts { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactController.shared.contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        let contact = ContactController.shared.contacts[indexPath.row]
        cell.textLabel?.text = contact.name
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = ContactController.shared.contacts[indexPath.row]
            ContactController.shared.delete(contact: contact) { (success) in
                print("␥ Successfully deleted \(contact.name) from iCloud")
                DispatchQueue.main.async {
                    ContactController.shared.contacts.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToUpdateContact" {
            guard let destinationVC = segue.destination as? ContactDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            let contactToUpdate = ContactController.shared.contacts[indexPath.row]
            destinationVC.contact = contactToUpdate
        }
    }
}
