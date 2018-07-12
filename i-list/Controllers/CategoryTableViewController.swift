//
//  CategoryTableViewController.swift
//  i-list
//
//  Created by Abdullah  Ali Shah on 05/04/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework
import CloudKit

class CategoryTableViewController: UITableViewController {
    
    //MARK:- Properties
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    var additionallNote = [Description]()
    var selectedItem : Item? {
        didSet{
            loadItems()
        }
    }
    //MARK:- View Loading Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.separatorStyle = .none
        tableView.rowHeight = 80.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cate", for: indexPath) as! SwipeTableViewCell
        
        let item = categories[indexPath.row]
        cell.textLabel?.text = item.name
        cell.delegate = self
        cell.backgroundColor = UIColor(hexString: categories[indexPath.row].color ?? "1D9BF6")
        cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: item.color!)!, returnFlat: true)
        return cell
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PrimaryViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    // MARK: - Data Manipulation Methods
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print ("Error saving context, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do {
          categories =  try context.fetch(request)
        } catch {
            print ("Following error occured during loading categories \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> =  Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate , additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from coredata \(error)")
        }
        tableView.reloadData()
    }
    
    func loadDescription(with request: NSFetchRequest<Description> =  Description.fetchRequest(), predicate: NSPredicate? = nil) {
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
    
    // MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategroy = Category(context: self.context)
            if textField.text?.isEmpty ?? true {
            self.AlertTextfieldIsEmpty()
            } else {
            newCategroy.name = textField.text!
            newCategroy.color = UIColor.randomFlat.hexValue()
            self.categories.append(newCategroy)
            self.saveCategories()
            }
        }
        let close = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(close)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func AlertTextfieldIsEmpty() {
        let alert = UIAlertController(title: "Warning" , message: "Please Enter The Name For The New Category Before Hittng Add", preferredStyle: .alert)
        let action = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveToCloud(_ sender: UIBarButtonItem) {
        print("Save to cloud pressed")
        
        // Sucess in saving Categories
        let Database = CKContainer.default().privateCloudDatabase
        for i in 0..<categories.count {
            let categoryColor = categories[i].color
            let categoryName = categories[i].name
            let newCategory = CKRecord(recordType: "Category")
            newCategory["Name"] = categoryName as CKRecordValue?
            newCategory["Color"] = categoryColor as CKRecordValue?
            // Saving items portion
            selectedCategory = categories[i]
            loadItems()
            for j in 0..<itemArray.count {
                let newTask = CKRecord(recordType: "Task")
                let reference = CKReference(record: newCategory, action: CKReferenceAction.deleteSelf)
                newTask["Category"] = reference
                newTask["Title"] = itemArray[j].title as CKRecordValue?
                // Saving additional text portion
                    selectedItem = itemArray[j]
                    loadDescription()
                    let newNote = CKRecord(recordType: "Description")
                    let referenceToTask = CKReference(record: newTask, action: CKReferenceAction.deleteSelf)
                    newNote["Task"] = referenceToTask
                    newNote["Note"] = selectedItem?.additionalNote?.additionalText as CKRecordValue?
                    newNote["Drawing"] = selectedItem?.additionalNote?.drawing as CKRecordValue?
                    Database.save(newNote, completionHandler: { (record: CKRecord?, error: Error?) in
                    if error == nil {
                        print("Additional description of tasks saved")
                        DispatchQueue.main.async(execute: {
                        })
                    } else {
                        print("Error: \(error.debugDescription)")
                    }
                })
                
                Database.save(newTask, completionHandler: { (record: CKRecord?, error: Error?) in
                    if error == nil {
                        print("Tasks saved")
                        DispatchQueue.main.async(execute: {
                        })
                    } else {
                        print("Error: \(error.debugDescription)")
                    }
                })
            }
            Database.save(newCategory, completionHandler: { (record: CKRecord?, error: Error?) in
                if error == nil {
                    print("Categories saved")
                    DispatchQueue.main.async(execute: {
                    })
                } else {
                    print("Error: \(error.debugDescription)")
                }
            })
        }
    }
}
// MARK: - Swipe Cell Delegate Methods
extension CategoryTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.context.delete(self.categories[indexPath.row])
            self.categories.remove(at: indexPath.row)
            self.saveCategories()
            tableView.reloadData()
        }
        // customize the action appearance
        // deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
    
    /*func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }*/
    
}
