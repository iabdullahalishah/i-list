//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Abdullah  Ali Shah on 29/04/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var label1: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        let sharedDefaults = UserDefaults.init(suiteName: "group.com.asadltd.ShareExtensionDemo")
        let todayDate = sharedDefaults?.value(forKey: "creationDate") as? Int
        label1.textColor = UIColor.darkGray
        let date = Date()
        let calendar = Calendar.current
        let currentDate = calendar.component(.day, from: date)
        if currentDate != todayDate {
            UserDefaults.standard.removeObject(forKey: "customKey")
            UserDefaults.standard.removeObject(forKey: "previousText")
            UserDefaults.standard.removeObject(forKey: "allowChange")
            label1.text = "   Nothing added yet"
            //UserDefaults.standard.removeObject(forKey: "customKey")
        } else {
            let text = sharedDefaults?.value(forKey: "customKey")
            let shouldChange = sharedDefaults?.value(forKey: "allowChange") as? Bool
            if shouldChange == true {
                if  let x = UserDefaults.standard.object(forKey: "previousText") as? String {
                    label1.text = (text as? String)! + ("\n\(x)")
                    UserDefaults.standard.set(label1.text, forKey: "previousText")
                } else {
                    label1.text = (text as? String)!
                    UserDefaults.standard.set(label1.text, forKey: "previousText")
                }
                print(text as Any)
                sharedDefaults?.setValue(false, forKey: "allowChange")
            } else {
                label1.text = UserDefaults.standard.object(forKey: "previousText") as? String
            }
        }
        print(todayDate!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 350)
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
