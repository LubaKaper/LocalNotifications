//
//  CreateNotificationsViewController.swift
//  LocalNotifications
//
//  Created by Liubov Kaper  on 2/20/20.
//  Copyright © 2020 Luba Kaper. All rights reserved.
//

import UIKit

protocol CreateNotifcationControllerDelegate: AnyObject {
    func didCreateNotification(_ createNotificationController: CreateNotificationsViewController)
}

class CreateNotificationsViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    

    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var delegate: CreateNotifcationControllerDelegate?
    
    private var timeInterval: TimeInterval = Date().timeIntervalSinceNow + 5 // current time plus 5 seconds
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    private func createLocalNotification() {
        // step 1: create the content
        let content = UNMutableNotificationContent()
        content.title = titleTextField.text ?? "No title"
        content.body = "Local Notifications is awesome when used right"
        content.subtitle = "Learning local notifications"
        
        content.sound = .default
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "file.mp3"))
        
        //TODO: userInfo  dictionary can hold additional data
        
        //create identifier
        let identifier = UUID().uuidString // unique string
        
        // create attachment
        // image has to be added to files, not in the assets folder
        if let imageURL = Bundle.main.url(forResource: "duck", withExtension: "png") {
            do {
                let attachment = try UNNotificationAttachment(identifier: identifier, url: imageURL, options: nil)
                content.attachments = [attachment]
            } catch {
                print("error with attacjment \(error)")
            }
        } else {
            print("image resource could not be found")
        }
        
        // create trigger
        // 3 possible triggers for local notifications: time interval, calendar, location
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false) // false because it is not recurring
        
        // create request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // add request to the UNNotificationCenter
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("error adding request: \(error)")
            } else {
                print("request was successfully added")
            }
        }
        
    }
    

    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        
        // to avoid time being in the past
        guard sender.date > Date() else { return }
        // timeintervalsincenow creates a time stamp of the exact date
        timeInterval = sender.date.timeIntervalSinceNow
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        
        createLocalNotification()
        delegate?.didCreateNotification(self)
        dismiss(animated: true)
    }
    
}
