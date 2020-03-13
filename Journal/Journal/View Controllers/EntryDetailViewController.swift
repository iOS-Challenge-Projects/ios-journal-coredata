//
//  ViewController.swift
//  Journal
//
//  Created by FGT MAC on 3/10/20.
//  Copyright © 2020 FGT MAC. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    
    
    
    //MARK: - Properties
    var entry: Entry? {
        didSet{
            updateViews()
           
        }
    }
    
    var entryController: EntryController?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        //Check if view has loaded before assigning values to fields
        if isViewLoaded{
            if let title = entry?.title, let details = entry?.bodyText, !title.isEmpty, !details.isEmpty  {
                titleTextField.text = title
                detailTextView.text = details
            }
        }
    }
    
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        guard let title = titleTextField.text, let details = detailTextView.text, !title.isEmpty, !details.isEmpty else { return }
        
        if entry != nil  {
            //Update current entry
            //TODO: Create update method
            if let title = titleTextField.text, let details = detailTextView.text, !title.isEmpty, !details.isEmpty  {
                
                //Here we are editing the current selection
                entry?.title = title
                entry?.bodyText = details
                entryController?.saveToPersistentStore()
                navigationController?.popViewController(animated: true)
            }
            

        }else{
            //Here we are creating a new entry
            entryController?.save(title: title, bodyText: details)
            navigationController?.popViewController(animated: true)
        }
    }
    
    
}

