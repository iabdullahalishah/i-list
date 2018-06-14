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
        label1.textColor = UIColor.blue
        //label1.text = ""
        //let str = "Swift 3.0 is the best version of Swift to learn, so if you're starting fresh you should definitely learn Swift 3.0."
        //let replaced = str.replacingOccurrences(of: "3.0", with: "4.0")
        //label1.text = replaced
        // Do any additional setup after loading the view from its nib.
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
