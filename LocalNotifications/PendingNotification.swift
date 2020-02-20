//
//  PendingNotification.swift
//  LocalNotifications
//
//  Created by Liubov Kaper  on 2/20/20.
//  Copyright © 2020 Luba Kaper. All rights reserved.
//

import Foundation
import UserNotifications

class PendingNotification {
    
    public func getPandingNotifications(complition: @escaping ([UNNotificationRequest]) -> ()) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            print("there are \(requests.count) pending requests")
            complition(requests)
        }
    }
    
}
