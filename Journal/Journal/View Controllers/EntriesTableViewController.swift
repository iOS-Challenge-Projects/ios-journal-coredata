//
//  EntriesTableViewController.swift
//  Journal
//
//  Created by FGT MAC on 3/10/20.
//  Copyright © 2020 FGT MAC. All rights reserved.
//

import UIKit

class EntriesTableViewController: UITableViewController {
    
    //MARK: - Properties
    let entryController = EntryController()

    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    
    @IBAction func completedButtonPressed(_ sender: UIButton) {
        print("Completed")
        let  entryCell = EntryTableViewCell()
        entryCell.changeButton()
        
    }
    
    
    // MARK: - Table view data source
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entryController.entries.count
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? EntryTableViewCell  else { return UITableViewCell()  }
        
        let entries = entryController.entries[indexPath.row]
      
        // Configure the cell...
        cell.entry = entries
        
        return cell
    }
 

 
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            //Get the target to be deleted
            let task = entryController.entries[indexPath.row]
            
            entryController.delete(task)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "CreateEntrySegue"{
            
            guard let createVC = segue.destination as? EntryDetailViewController else { return }
            
            createVC.entryController = entryController
            
        } else if segue.identifier == "DetailSegue"{
            
            guard let detailVC = segue.destination as? EntryDetailViewController else { return }
            
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let entries = entryController.entries[indexPath.row]
            
            detailVC.entry = entries
            
            detailVC.entryController = entryController
        }
    }
 

}
