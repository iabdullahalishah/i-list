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
import ChromaColorPicker

class DescriptionViewController: UIViewController, ChromaColorPickerDelegate {
    
    //MARK:- Properties
    var additionallNote = [Description]()
    @IBOutlet weak var drawingPad: UIImageView!
    @IBOutlet weak var switchBetweenTextAndSketch: UIButton!
    var lastPoint: CGPoint = CGPoint(x: 0, y: 0)
    var currentColor = UIColor.blue.cgColor
    var brushSize: Float = 30.0
    var colorPicker: ChromaColorPicker?
    var composeButtonTapped = false
    var writting = true
    var greyedOut = UIView()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedItem : Item? {
        didSet{
            loadItems()
        }
    }
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    //MARK:- View Loading fucntions
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.text = selectedItem?.additionalNote?.additionalText
        descriptionTextView.textColor = UIColor(hexString: (selectedItem?.parentCategory?.color)!)
        if let imageData = selectedItem?.additionalNote?.drawing {
            drawingPad.image = UIImage(data: imageData)
        }
        greyedOut = UIView(frame: view.frame)
        greyedOut.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.addSubview(greyedOut)
        colorPicker = ChromaColorPicker(frame: CGRect(x: view.frame.size.width / 2 - 100 , y: view.frame.size.height / 2 - 100, width: 200, height: 200))
        if let picker = colorPicker {
            picker.delegate = self
            picker.padding = 5
            picker.stroke = 3
            picker.hexLabel.isHidden = true
            view.addSubview(picker)
        }
        colorPicker?.isHidden = true
        greyedOut.isHidden = true
        buttonsStackView.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedItem?.title
        guard let colorHex = selectedItem?.parentCategory?.color else {fatalError()}
        updateNavBar(withHexCode: colorHex)
    }
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        currentColor = color.cgColor
        colorPicker.isHidden = true
        greyedOut.isHidden = true
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
        if writting == true {
        selectedItem?.additionalNote?.additionalText = descriptionTextView.text
        additionallNote.append(newDescription)
        saveDescription() } else {
            if let image = drawingPad.image {
            //selectedItem?.additionalNote?.drawing =
                selectedItem?.additionalNote?.drawing = UIImageJPEGRepresentation(image, 1)
                saveDescription()
            }
        }
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
    
    @IBAction func composeButtonTapped(_ sender: UIBarButtonItem) {
        
        drawingPad.isHidden = false
        descriptionTextView.isHidden = true
        buttonsStackView.isHidden = false
        writting = false
    }
    
    
    @IBAction func switchBetweenTextAndDrawingButton(_ sender: UIButton) {
        
        if switchBetweenTextAndSketch.currentImage == #imageLiteral(resourceName: "sketchbook"){
            switchBetweenTextAndSketch.setImage(#imageLiteral(resourceName: "text"), for: .normal)
            drawingPad.isHidden = false
            descriptionTextView.isHidden = true
            buttonsStackView.isHidden = false
            writting = false
        } else if switchBetweenTextAndSketch.currentImage == #imageLiteral(resourceName: "text") {
            switchBetweenTextAndSketch.setImage(#imageLiteral(resourceName: "sketchbook"), for: .normal)
            drawingPad.isHidden = true
            descriptionTextView.isHidden = false
            buttonsStackView.isHidden = true
            writting = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonsStackView.isHidden = true
        if let beginPoint = touches.first?.location(in: drawingPad) {
            lastPoint = beginPoint
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let movedPoint = touches.first?.location(in: drawingPad) {
            drawBetweenTwoPoints(point1: lastPoint, point2: movedPoint)
            lastPoint = movedPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let endPoint = touches.first?.location(in: drawingPad) {
            drawBetweenTwoPoints(point1: lastPoint, point2: endPoint)
        }
        buttonsStackView.isHidden = false
    }
    
    func drawBetweenTwoPoints(point1: CGPoint, point2: CGPoint) {
        UIGraphicsBeginImageContext(drawingPad.frame.size)
        drawingPad.image?.draw(in: CGRect(x: 0, y: 0, width: drawingPad.frame.size.width, height: drawingPad.frame.size.height))
        if let context = UIGraphicsGetCurrentContext(){
            context.move(to: point1)
            context.addLine(to: point2)
            context.setLineWidth(CGFloat(brushSize) / 3.0)
            context.setLineCap(.round)
            context.setStrokeColor(currentColor)
            context.strokePath()
            drawingPad.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }
    
    @IBAction func colorPaletteButtonTapped(_ sender: UIButton) {
        colorPicker?.adjustToColor(UIColor(cgColor: currentColor))
        colorPicker?.isHidden = false
        greyedOut.isHidden = false
    }
    
    @IBAction func brushButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Brush Size", message: "\n\n\n\n", preferredStyle: .alert)
        let slider = UISlider(frame: CGRect(x: 10, y: 50, width: 250, height: 80))
        slider.minimumValue = 1
        slider.maximumValue = 100
        slider.value = brushSize
        alert.view.addSubview(slider)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (alert) in
            self.brushSize = slider.value
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func eraserButtonTapped(_ sender: UIButton) {
        currentColor = UIColor.white.cgColor
    }
    
    @IBAction func trashButtonTapped(_ sender: UIButton) {
        drawingPad.image = nil
    }
    
}
