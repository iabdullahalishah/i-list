//
//  DescriptionViewController.swift
//  i-list
//
//  Created by Abdullah  Ali Shah on 14/04/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class DescriptionViewController: UIViewController {
    
    var additionallNote = [Description]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedItem : Item? {
        didSet{
            loadItems()
        }
    }
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //newDescription.additionalText = descriptionTextView.text!
        descriptionTextView.text = selectedItem?.additionalNote?.additionalText
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let newDescription = Description(context: context)
        newDescription.additionalText = descriptionTextView.text!
        newDescription.parentItem = selectedItem
        selectedItem?.additionalNote?.additionalText = descriptionTextView.text
        additionallNote.append(newDescription)
        saveDescription()
    }
    
    func saveDescription() {
        do {
            try context.save()
            print("Data is saved")
            
        } catch {
            print ("Error saving context, \(error)")
        }

    }
    
    func loadItems(with request: NSFetchRequest<Description> =  Description.fetchRequest(), predicate: NSPredicate? = nil) {
        let itemPredicate = NSPredicate(format: "parentItem.title MATCHES %@", selectedItem!.title!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [itemPredicate , additionalPredicate])
        } else {
            request.predicate = itemPredicate
        }
        
        do {
            additionallNote = try context.fetch(request)
        } catch {
            print("Error fetching data from coredata \(error)")
        }
    }
}
