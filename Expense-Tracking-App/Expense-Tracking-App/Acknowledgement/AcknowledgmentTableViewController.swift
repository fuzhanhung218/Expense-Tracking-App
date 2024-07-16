//
//  AcknowledgmentTableViewController.swift
//  FIT3178-Final-App
//
//  Created by Fu Zhan Hung on 5/6/2024.
//

import UIKit

class AcknowledgmentTableViewController: UITableViewController {

    var libraries = ["Firebase", "SwiftCharts", "ExchangeRate-API"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.sectionHeaderTopPadding = 10
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return libraries.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Third Party Libraries"
    }
    
    /// Configures each table view cell with the expense name and amount.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryCell", for: indexPath)
        
        let row = indexPath.row
        
        cell.textLabel?.text = libraries[row]

        return cell
    }


    // MARK: - Navigation
    
    /// Prepares for a segue to the ExpenseDetailTableViewController.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLicense" {
            if let indexPath = self.tableView.indexPathForSelectedRow { // Get the index path of the selected row
                let selectedLibrary = libraries[indexPath.row]
                
                // Pass the selected expense to the destination view controller
                let destination = segue.destination as! LicenseViewController
                destination.library = selectedLibrary
            }
        }
    }
    
    

}
