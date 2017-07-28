//
//  ChecklistItemsData.swift
//  Checklist
//
//  Created by Abdullah Adwan on 5/23/17.
//  Copyright © 2017 Abdullah Adwan. All rights reserved.
//

import Foundation
import UserNotifications

class ChecklistItem: NSObject, NSCoding {
    
    var text: String = ""
    var checked: Bool = false
    var dueDate =  Date()
    var shouldRemind = false
    var itemID: Int
    
    
    init(itemText text: String, checkmarkChecked checked: Bool) {
        self.checked = checked
        self.text = text
        itemID = ChecklistsDataModel.nextChecklistItemID()
    }
    
    func UpdateText(updatedText text: String) {
        self.text = text
    }
    
    func UpateCheckmarkStatus() {
        self.checked = !self.checked
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: "Text")
        aCoder.encode(checked, forKey: "Checked")
        aCoder.encode(dueDate, forKey: "DueDate")
        aCoder.encode(shouldRemind, forKey: "ShouldRemind")
        aCoder.encode(itemID, forKey: "ItemID")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = aDecoder.decodeObject(forKey: "Text") as! String
        self.checked = aDecoder.decodeBool(forKey: "Checked")
        self.dueDate = aDecoder.decodeObject(forKey: "DueDate") as! Date
        self.shouldRemind = aDecoder.decodeBool(forKey: "ShouldRemind")
        self.itemID = aDecoder.decodeInteger(forKey: "ItemID")
        super.init()
    }
    
    func scheduleNotification() {
        removeNotification()
        if shouldRemind && dueDate > Date() {
            if #available(iOS 10.0, *) {
                let content = UNMutableNotificationContent()
                content.title = "Reminder"
                content.body = self.text
                content.sound = UNNotificationSound.default()
                
                let calendar = Calendar(identifier: .gregorian)
                let components = calendar.dateComponents(
                    [.month, .day, .hour, .minute], from: dueDate)
            
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: components, repeats: true)
                
                let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
                
                let center = UNUserNotificationCenter.current()
                center.add(request)
                
                print("Scheduled notification \(request) for itemID \(itemID)")
            } else {
                // Fallback on earlier versions
            }
           
            
        }
    }
    
    func removeNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(
                withIdentifiers: ["\(itemID)"])
        } else {
            // Fallback on earlier versions
        }
       
    }
    
    deinit {
        removeNotification()
    }
}
