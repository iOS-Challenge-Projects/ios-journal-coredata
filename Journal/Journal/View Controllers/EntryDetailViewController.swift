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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    
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
            if let title = entry?.title, let details = entry?.bodyText{
                titleTextField.text = title
                detailTextView.text = details
                
                //Set the current mood
                let mood: EntryMood
                if let entryMood = entry?.mood{
                    mood = EntryMood(rawValue: entryMood) ?? .normal
                }else{
                    mood = .normal
                }
                segmentedControl.selectedSegmentIndex = EntryMood.allCases.firstIndex(of: mood) ?? 1
                
            }
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        guard let title = titleTextField.text, let details = detailTextView.text, !title.isEmpty else { return }
        
        if entry != nil  {
            //Update current entry

            //Here we are editing the current selection
            entry?.title = title
            entry?.bodyText = details
            let seletedMoodIndex = segmentedControl.selectedSegmentIndex
            let mood = EntryMood.allCases[seletedMoodIndex]
            entry?.mood = mood.rawValue
            //Also update date to the current date of the update
            entry?.timestamp = Date()
            entryController?.saveToPersistentStore()
            navigationController?.popViewController(animated: true)

        }else{
            //Here we are creating a new entry
            //Get the Int from the seleted segmented control
            let moodIndex = segmentedControl.selectedSegmentIndex
            
            entryController?.save(title: title, bodyText: details,seletedMoodIndex: moodIndex)
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    
}

