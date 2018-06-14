//
//  SummaryViewController.swift
//  i-list
//
//  Created by Abdullah  Ali Shah on 29/04/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class SummaryViewController: UIViewController {
    
    var additionallNote = [Description]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedItem : Item? {
        didSet{
            loadItems()
        }
    }
    
    @IBOutlet weak var addToTodaysListButton: UIButton!
    
    @IBOutlet weak var categoryResult: UILabel!
    
    @IBOutlet weak var itemResult: UILabel!
    
    @IBOutlet weak var descriptionResult: UITextView!
    
    var allText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let x = selectedItem?.additionalNote?.additionalText!
        let y = selectedItem?.parentCategory?.name!
        let z = selectedItem?.title!
        categoryResult.text = y
        itemResult.text = z
        if x != nil {
        descriptionResult.text = x
        allText = "    Category: \(String(describing: y!)) \n    Item: \(String(describing: z!)) \n    Description:\(String(describing: x!)) \n    〰〰〰〰〰〰〰〰〰〰〰〰〰"
        } else {descriptionResult.text = "Nil"
            allText = "    Category: \(String(describing: y!)) \n    Item: \(String(describing: z!)) \n    Description: nil \n    〰〰〰〰〰〰〰〰〰〰〰〰〰" }
        print(allText)
        // Do any additional setup after loading the view. \(String(describing: x!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        addToTodaysListButton.backgroundColor = navBarColor
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
    
    @IBAction func addToTodaysListTapped(_ sender: UIButton) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.asadltd.ShareExtensionDemo")
        sharedDefaults?.setValue(allText, forKey: "customKey")
        sharedDefaults?.setValue(true, forKey: "allowChange")
    }
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        let activityController = UIActivityViewController(activityItems: [allText], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
}
