//
//  ViewController.swift
//  i-list
//
//  Created by Abdullah  Ali Shah on 05/04/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework
class PrimaryViewController: UITableViewController {
    
    //MARK:- Properties
    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    var itemSelected: Item? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK:- View Loading Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.rowHeight = 80.0
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: - Setting Colors of Cells
    
    override func viewWillAppear(_ animated: Bool) {
            title = selectedCategory!.name
            guard let colorHex = selectedCategory?.color else {fatalError()}
            updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    // MARK: - Nav Bar Setup methods
    
    func updateNavBar(withHexCode colorHexCode: String){
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller doesnt Exists")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! SwipeTableViewCell
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        if let color = UIColor(hexString: selectedCategory!.color!)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count))
        {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        cell.accessoryType = item.done ? .checkmark : .none
        cell.delegate = self
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK:- Segue Code
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDescription"{
        let destinationVC = segue.destination as! DescriptionViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedItem = itemArray[indexPath.row]
        } else {
            destinationVC.selectedItem = itemSelected
            print("Holo is triggered")
            }
        }
        if segue.identifier == "TimerNotificationFromTasks" {
            let destinationVC = segue.destination as! NotificationsViewController
            destinationVC.triggerIndentifier = (itemSelected?.title)!
            destinationVC.mainCategory = (itemSelected?.parentCategory?.name)!
            //let colorHex = selectedCategory?.color
            //guard let titleColorrr = UIColor(hexString: colorHex!) else {fatalError()}
            //destinationVC.titleOfDatePicker?.textColor? = titleColorrr
            }
        if segue.identifier == "toGeoNotificationView" {
            let destinationVC = segue.destination as! GeoNotificationViewController
            destinationVC.notificationTitle = (itemSelected?.title)!
            destinationVC.notificationSubTitle = (itemSelected?.parentCategory?.name)!
            }
        if segue.identifier == "toSummary"{
            let destinationVC = segue.destination as! SummaryViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedItem = itemArray[indexPath.row]
            } else {
                destinationVC.selectedItem = itemSelected
                print("Holo is triggered")
            }
        }
    }
    
    //MARK: - Add New Items

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New I-LIST Item" , message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "✅", style: .default) { (action) in
            let newItem = Item(context: self.context)
            
            if textField.text?.isEmpty ?? true {
                self.AlertTextfieldIsEmpty()
            }
                
            else {
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
            }
            
        }
        
        let close = UIAlertAction(title: "❌", style: .cancel, handler: nil)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
    
    func AlertTextfieldIsEmpty() {
        let alert = UIAlertController(title: "Warning" , message: "Please Enter The Name For New Item Before Hittng Add", preferredStyle: .alert)
        let action = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupulation Methods
    
    func saveItems() {
        do {
            try context.save()

        } catch {
            print ("Error saving context, \(error)")
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
}

//MARK: - Search bar methods and Swipe methods
extension PrimaryViewController: UISearchBarDelegate, SwipeTableViewCellDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: predicate)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                 searchBar.resignFirstResponder()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        itemSelected = itemArray[indexPath.row]
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.context.delete(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
            self.saveItems()
            tableView.reloadData()
        }
        let moreAction = SwipeAction(style: .default, title: "More") { action, indexPath in
            // handle action by updating model with deletion
            
            let alertController = UIAlertController(title: "Confirm?", message: "Would you like to confirm this action?", preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
                print("User tapped Cancel")
            }
            
            let descriptionAction = UIAlertAction(title: "Add Note", style: .default, handler: { (alert) in
                print("User tapped description")
                self.performSegue(withIdentifier: "toDescription", sender: self)
            })
            
            let dateNotificationAction = UIAlertAction(title: "Set Time Notification", style: .default, handler: { (alert) in
                print("User tapped notification action")
                self.performSegue(withIdentifier: "TimerNotificationFromTasks", sender: self)
            })
            
            let GeoNotificationAction = UIAlertAction(title: "Set Location", style: .default, handler: { (alert) in
                print("User tapped notification action")
                self.performSegue(withIdentifier: "toGeoNotificationView", sender: self)
            })
            
            let SummaryAction = UIAlertAction(title: "Summary", style: .default, handler: { (alert) in
                print("User tapped notification action")
                self.performSegue(withIdentifier: "toSummary", sender: self)
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(descriptionAction)
            alertController.addAction(dateNotificationAction)
            alertController.addAction(GeoNotificationAction)
            alertController.addAction(SummaryAction)
            //alertController.popoverPresentationController?.sourceRect = self.view.frame
            alertController.popoverPresentationController?.sourceView = self.view
            self.present(alertController, animated: true, completion: nil)
        }

        // customize the action appearance
        // deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction,moreAction]
    }

}


