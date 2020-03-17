//
//  EntriesTableViewController.swift
//  Journal
//
//  Created by FGT MAC on 3/10/20.
//  Copyright © 2020 FGT MAC. All rights reserved.
//

import UIKit
import CoreData

class EntriesTableViewController: UITableViewController {
    
    //MARK: - Properties
    let entryController = EntryController()
    
    
    
    //Store property to only start fetching when needed
    lazy var fetchedResultsController: NSFetchedResultsController<Entry> = {
        
        //1.Initiate the fetch request
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        
        //2.Array of sortDescriptors to Sort data
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "mood", ascending: true),NSSortDescriptor(key: "timestamp", ascending: true)]
        
        //3.CoreData stack context
        let context = CoreDataStack.shared.mainContext
        
        //4.Initialize NSFetchedResultsController
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "mood", cacheName: nil)
        //5.SET CLASS AS DELEGATE
        frc.delegate = self
        //6.Perform fetch
        try? frc.performFetch()
        return frc
    }()
    
    
    
    
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
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Old way using the entryController
        //return entryController.entries.count
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? EntryTableViewCell  else { return UITableViewCell()  }
        
        let entries = fetchedResultsController.object(at: indexPath)
      
        // Configure the cell...
        cell.entry = entries
        
        return cell
    }
 

 
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            //Get the target to be deleted
            let task = fetchedResultsController.object(at: indexPath)
            
            entryController.delete(task)
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
            
            let entries = fetchedResultsController.object(at: indexPath)
            
            detailVC.entry = entries
            
            detailVC.entryController = entryController
        }
    }
 

}



//MARK: - TasksTableViewController


extension EntriesTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //When a change is detected we begin updates
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //when we finish with changes we end updates
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        //Add or remove entire sections from the view
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
         case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //moving inserting or deleting multiple rows
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}
