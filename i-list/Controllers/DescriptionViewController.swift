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
    
    //MARK:- Properties
    var additionallNote = [Description]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedItem : Item? {
        didSet{
            loadItems()
        }
    }
    @IBOutlet weak var descriptionTextView: UITextView!
    
    //MARK:- View Loading fucntions
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.text = selectedItem?.additionalNote?.additionalText
        descriptionTextView.textColor = UIColor(hexString: (selectedItem?.parentCategory?.color)!)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedItem?.title
        guard let colorHex = selectedItem?.parentCategory?.color else {fatalError()}
        updateNavBar(withHexCode: colorHex)
    }
    
    func updateNavBar(withHexCode colorHexCode: String){
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller doesnt Exists")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
    }
    
    //MARK:- Function for Save Button
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let newDescription = Description(context: context)
        newDescription.additionalText = descriptionTextView.text!
        newDescription.parentItem = selectedItem
        selectedItem?.additionalNote?.additionalText = descriptionTextView.text
        additionallNote.append(newDescription)
        saveDescription()
    }
    
    //MARK:- Saving and loadings functions
    
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
