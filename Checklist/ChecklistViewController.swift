//
//  ChecklistViewController.swift
//  Checklist
//
//  Created by Abdullah Adwan on 5/22/17.
//  Copyright © 2017 Abdullah Adwan. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController, AddOrEditItemViewControllerDelegate {
    
    // MARK: Properties
    
    var checklist: Checklist!

    // MARK: Methods
    
        //configure the status of checkmarks for each row
    private func configureCheckmark(for cell: UITableViewCell, at indexPath: IndexPath) {
        
        let label = cell.viewWithTag(55) as! UILabel
        label.tintColor = view.tintColor
        if checklist.items[indexPath.row].checked {
            label.text = "✓"
        } else {
            label.text = ""
        }
    
        
    }
        //configure the text for a cell
    private func configueTextForCell(for cell: UITableViewCell, with item: ChecklistItem) {
        let label = cell.viewWithTag(33) as! UILabel
        //label.text = text
        
        label.text = "\(item.text)"
    }
    
    
       // addOrEditItemViewControllerDidCancel Delegation //
    func addOrEditItemViewControllerDidCancel(_ controller: AddOrEditItemViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addOrEditItemViewController(_ controller: AddOrEditItemViewController, didFinishAdding item: ChecklistItem) {
        addItem(item: item)
        dismiss(animated: true, completion: nil)
    }
    
    func addOrEditItemViewController(_ controller: AddOrEditItemViewController, didFinishEditing item: ChecklistItem) {
        if let index = checklist.items.index(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configueTextForCell(for: cell, with: item)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    

    //MARK Actions
    
    func addItem(item: ChecklistItem) {
        let newItemIndex = checklist.items.count
        checklist.items.append(item)
        
        let indexPath = IndexPath(row: newItemIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist.items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        
        configueTextForCell(for: cell, with: checklist.items[indexPath.row])
        configureCheckmark(for: cell, at: indexPath)
        return cell
    }
 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let cell = tableView.cellForRow(at: indexPath){
            
            checklist.items[indexPath.row].UpateCheckmarkStatus()
            configureCheckmark(for: cell, at: indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
 
    }
    
    override func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        checklist.items.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.visibleViewController as! AddOrEditItemViewController
            controller.delegate = self
            navigationController.navigationBar.backgroundColor = UIColor.black
            navigationController.navigationBar.tintColor = UIColor.darkText
            
        } else if segue.identifier == "EditItem" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.visibleViewController as! AddOrEditItemViewController
            
            navigationController.title = "Edit Item"
            navigationController.navigationBar.backgroundColor = UIColor.black
            navigationController.navigationBar.tintColor = UIColor.darkText
            controller.delegate = self
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.itemToEdit = checklist.items[indexPath.row]
            }
        }
    }
}
