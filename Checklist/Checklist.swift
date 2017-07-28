//
//  Checklist.swift
//  Checklists
//
//  Created by Abdullah Adwan on 5/27/17.
//  Copyright © 2017 Abdullah Adwan. All rights reserved.
//

import Foundation

class Checklist: NSObject, NSCoding {
    var name: String
    var items: [ChecklistItem] = []
    var iconName: String
    
    init(listName: String, iconName: String = "No Icon") {
        self.name = listName
        self.iconName = iconName
        super.init()
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "ListName")
        aCoder.encode(items, forKey: "ListItems")
        aCoder.encode(iconName, forKey: "IconName")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "ListName") as! String
        self.items = aDecoder.decodePropertyList(forKey: "ListItems") as! [ChecklistItem]
        self.iconName = aDecoder.decodeObject(forKey: "IconName") as! String
        super.init()
    }
    
    func countUncheckedItems() -> Int {
        var count = 0
        for item in items where !item.checked {
            count += 1
        }
        return count
    }
}
