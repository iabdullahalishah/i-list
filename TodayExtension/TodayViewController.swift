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
        if let x = UserDefaults.standard.object(forKey: "previousText") as? String {
            label1.text = (text as? String)! + ("\n\(x)")
            UserDefaults.standard.set(label1.text, forKey: "previousText")
        } else {
            label1.text = (text as? String)!
            UserDefaults.standard.set(label1.text, forKey: "previousText")
        }
        print(text as Any)
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
            self.preferredContentSize = CGSize(width: maxSize.width, height: 150)
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
