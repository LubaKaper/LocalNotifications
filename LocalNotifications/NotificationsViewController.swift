//
//  ViewController.swift
//  LocalNotifications
//
//  Created by Liubov Kaper  on 2/20/20.
//  Copyright © 2020 Luba Kaper. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var notifications = [UNNotificationRequest]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // singleton
    private let center = UNUserNotificationCenter.current()
    
    private let pendingNotification = PendingNotification()
    
    private var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        configureRefreshControl()
        checkForNotificationAuthorization()
        
        loadNotifications()
        
        // setting this view controller as the UNNotoficationCenterDelegate
        center.delegate = self
    }
    
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadNotifications), for: .valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navController = segue.destination as? UINavigationController, let createVC = navController.viewControllers.first as? CreateNotificationsViewController else {
            fatalError("could not downcast to CreateNotificationsViewController")
        }
        createVC.delegate = self
    }
    
   @objc private func loadNotifications() {
        pendingNotification.getPandingNotifications { (requests) in
            self.notifications = requests
            // stop refresh control from animating and remove from UI
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    // checks if permission wAS already given
    private func checkForNotificationAuthorization() {
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                print("app is authorized for notifications")
            } else {
                self.requestNotificationPermission()
            }
        }
    }

    // function that requests permission from user
    private func requestNotificationPermission() {
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("error requesting authorization \(error)")
                return
            }
            if granted {
                print("access was granted")
            } else {
                print("sccess denied")
            }
        }
    }

}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        let notification = notifications[indexPath.row]
        cell.textLabel?.text = notification.content.title
        cell.detailTextLabel?.text = notification.content.body
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // we will delete the pending notification
            removeNotification(atIndexPath: indexPath)
        }
    }
    private func removeNotification(atIndexPath indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        let identifier = notification.identifier
        // remove from UNnotificationCenter
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        // remove from array of notifications
        notifications.remove(at: indexPath.row)
        // remove from tableView
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
}

// this to get notification to show when inside the app
extension NotificationsViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

extension NotificationsViewController: CreateNotifcationControllerDelegate {
    func didCreateNotification(_ createNotificationController: CreateNotificationsViewController) {
        loadNotifications()
    }
    
    
}
