//
//  DataModel.swift
//  Checklists
//
//  Created by Abdullah Adwan on 5/28/17.
//  Copyright © 2017 Abdullah Adwan. All rights reserved.
//

import Foundation

class ChecklistsDataModel {
    
    // MARK: Properties
    
    var lists = [Checklist]()
    var indexOfSelectedChecklist: Int {
        get {
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
        }
    }
    
    
    // MARK: Initializtion

    init() {
        loadChecklists()
        registerDefaults()
        handleAppFirstTimeUse()
    }
    
    // MARK: Data Model Presistance
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    
    func saveChecklists() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(lists, forKey: "Checklists")
        archiver.finishEncoding()
        data.write(to: dataFilePath(), atomically: true)
    }
    
    func loadChecklists() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            lists = unarchiver.decodeObject(forKey: "Checklists") as! [Checklist]
            unarchiver.finishDecoding()
        }
        sortChecklists()
    }
    
    // MARK: User Defaults
    
    func registerDefaults()  {
        let dict: [String: Any] = ["ChecklistIndex": -1,
                                   "FirstTime": true,
                                   "ChecklistItemID": 1000]
        UserDefaults.standard.register(defaults: dict)
    }
    
    func handleAppFirstTimeUse() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        
        if firstTime {
            lists.append(Checklist(listName: "List", iconName: "Folder"))
            indexOfSelectedChecklist = 0
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
            
        }
    }
    
    class func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = userDefaults.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        userDefaults.synchronize()
        return itemID
    }
    
    // MARK: Sorting 
    
    func sortChecklists() {
        lists.sort(by: {checklist1, checklist2 in
                    return checklist1.name.localizedCompare(checklist2.name) == .orderedAscending })
    }
    
    
}
