//
//  EntryTableViewCell.swift
//  Journal
//
//  Created by FGT MAC on 3/10/20.
//  Copyright © 2020 FGT MAC. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    //MARK: - Properties
    
    var entry: Entry? {
        didSet{
             
            updateViews() 
        }
    }
    
    
    
    private func updateViews()  {
        guard let title = entry?.title, let details = entry?.bodyText   else {return}
   
        titleLabel.text = title
        bodyTextLabel.text = details
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy"
//        let dateString = dateFormatter.string(from: date as Date)
//
//        dateLabel.text = dateString
    }

}
