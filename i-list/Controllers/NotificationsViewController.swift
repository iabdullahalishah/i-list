//
//  NotificationsViewController.swift
//  i-list
//
//  Created by Abdullah  Ali Shah on 15/04/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import UIKit
import UserNotifications
class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    let notificationCenter = UNUserNotificationCenter.current()
    var datePickerIsSelected = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkNotificationAuthorization()
        if datePickerIsSelected {
            datePicker.datePickerMode = .dateAndTime
        } else {
            datePicker.datePickerMode = .countDownTimer
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestNotificationAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge];
        
        notificationCenter.requestAuthorization(options: options) { (granted, error) in
            if granted {
                print("Accepted permission.")
            } else {
                print("Did not accept permission.")
            }
        }
    }
    
    func checkNotificationAuthorization() {
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                print("Notifications are authorized")
                if (settings.soundSetting == .disabled) {
                    print("Sound is disabled")
                }
            } else if settings.authorizationStatus == .denied {
                self.requestNotificationAuthorization()
                print("Notifications have been denied")
            } else {
                print("Notifications authorization dialog hasn't been shown yet")
            }
        }
    }
    
    @IBAction func showNotification(_ sender: Any) {
        let content = setContent()
        if datePickerIsSelected {
            let date = setDate()
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
            let request = UNNotificationRequest(identifier: "OverdueTasksNotification", content: content, trigger: trigger)
            notificationCenter.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print("Couldn't add notification. Error: \(error)")
                }
            })
            dismiss(animated: true, completion: nil)
        } else {
            let interval = setTimer()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: "OverdueTasksNotification", content: content, trigger: trigger)
            notificationCenter.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print("Couldn't add notification. Error: \(error)")
                }
            })
        }
    }
    
    func setContent() -> UNMutableNotificationContent
    {
        let content = UNMutableNotificationContent()
        content.title = "Sweet Phudi"
        content.body = "You have fuck phudi"
        content.sound = UNNotificationSound.default()
        content.badge = 15
        return content
    }
    
    func setDate() -> DateComponents {
        var date = DateComponents()
        let dateCurrent = datePicker.date
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute], from: dateCurrent)
        date.day = components.day;date.month = components.month;date.year = components.year;date.hour = components.hour;
        date.minute = components.minute
        return date
    }
    
    func setTimer() -> TimeInterval{
        print(datePicker.countDownDuration)
        return datePicker.countDownDuration
    }
    
    
    
}
