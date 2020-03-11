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
            //Create update method
            navigationController?.popViewController(animated: true)
            print("Update EntryDetailViewController")
        }else{
            entryController?.save(title: title, bodyText: details)
            print("Create EntryDetailViewController")
            navigationController?.popViewController(animated: true)
        }
    }
    
    
}

