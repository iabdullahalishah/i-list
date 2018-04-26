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
    
    //MARK:- IBOutles
    @IBOutlet weak var titleOfDatePicker: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var switchTimerOutlet: UIButton!
    //MARK:- Properties
    let notificationCenter = UNUserNotificationCenter.current()
    var datePickerIsSelected = true
    var triggerIndentifier = ""
    var mainCategory = ""
    
    //MARK:- VIEW loading Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        requestNotificationAuthorization()
        checkNotificationAuthorization()
        titleOfDatePicker.text = triggerIndentifier
        popupView.layer.cornerRadius = 20
        popupView.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /*if datePickerIsSelected {
         datePicker.datePickerMode = .dateAndTime
         } else {
         datePicker.datePickerMode = .countDownTimer
         }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Notification checking and authorization
    
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
    
    @IBAction func switchTimeSelector(_ sender: UIButton) {
        if switchTimerOutlet.currentImage == #imageLiteral(resourceName: "sand-clock"){
            switchTimerOutlet.setImage(#imageLiteral(resourceName: "schedule"), for: .normal)
            datePickerIsSelected = true
            datePicker.datePickerMode = .dateAndTime
            print("Sand clock is tapped")
        } else if switchTimerOutlet.currentImage == #imageLiteral(resourceName: "schedule") {
            switchTimerOutlet.setImage(#imageLiteral(resourceName: "sand-clock"), for: .normal)
            datePickerIsSelected = false
            datePicker.datePickerMode = .countDownTimer
            print("Calendar is tapped")
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
    
    //MARK:- Function for set notification
    
    @IBAction func showNotification(_ sender: Any) {
        let content = setContent()
        if datePickerIsSelected {
            let date = setDate()
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
            let request = UNNotificationRequest(identifier: triggerIndentifier, content: content, trigger: trigger)
            notificationCenter.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print("Couldn't add notification. Error: \(error)")
                }
            })
            dismiss(animated: true, completion: nil)
        } else {
            let interval = setTimer()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: triggerIndentifier, content: content, trigger: trigger)
            notificationCenter.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print("Couldn't add notification. Error: \(error)")
                }
            })
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK:- Cancel Button Function
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    //MARK:- Functions for setting content, date, or timer
    
    func setContent() -> UNMutableNotificationContent
    {
        let content = UNMutableNotificationContent()
        content.title = mainCategory
        content.body = "You have been notified for \(triggerIndentifier)"
        content.sound = UNNotificationSound.default()
        content.badge = 1
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
