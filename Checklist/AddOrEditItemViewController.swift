//
//  AddItemTableViewController.swift
//  Checklist
//
//  Created by Abdullah Adwan on 5/24/17.
//  Copyright © 2017 Abdullah Adwan. All rights reserved.
//

import UIKit
import UserNotifications

class AddOrEditItemViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    weak var delegate: AddOrEditItemViewControllerDelegate!
    var itemToEdit: ChecklistItem?
    var dueDate = Date()
    var datePickerVisible = false

    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateTextLabel: UILabel!
    @IBOutlet weak var newItemTextField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet var datePickerCell: UITableViewCell!
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let item = itemToEdit {
            title = "Edit Item"
            newItemTextField.text = item.text
            doneButton.isEnabled = true
            shouldRemindSwitch.isOn = item.shouldRemind
            dueDate = item.dueDate
        }
        
        updateDueDateLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //newItemTextField.becomeFirstResponder()
        newItemTextField.delegate = self
    }
    
    func updateDueDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dueDateTextLabel.text = formatter.string(from: dueDate)
    }
    
    func showDatePicker() {
        datePickerVisible = true
        
        let datePickerIndexPath = IndexPath(row: 2, section: 1)
        let indexPathDateRow = IndexPath(row: 1, section: 1)
        
        if let dateCell = tableView.cellForRow(at: indexPathDateRow) {
            dateCell.detailTextLabel!.textColor =
                view.tintColor
        }
        
        tableView.beginUpdates()
        tableView.insertRows(at: [datePickerIndexPath], with: .fade)
        tableView.reloadRows(at: [indexPathDateRow], with: .none)
        tableView.endUpdates()
        
        datePicker.setDate(dueDate, animated: true)
    }
    
    func hideDatePicker() {
        datePickerVisible = false
        
        let datePickerIndexPath = IndexPath(row: 2, section: 1)
        let indexPathDateRow = IndexPath(row: 1, section: 1)
        
        if let dateCell = tableView.cellForRow(at: indexPathDateRow) {
            dateCell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
        }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPathDateRow], with: .none)
        tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
        tableView.endUpdates()
        
        datePicker.setDate(dueDate, animated: true)
    }
    
    // MARK: Text field delegate methods 
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneButton.isEnabled = newText.length > 0
        
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if datePickerVisible {
            hideDatePicker()
        }
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 2 {
            return datePickerCell
        } else {
           return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datePickerVisible && section == 1 {
            return 3
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 && indexPath.section == 1 {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        newItemTextField.resignFirstResponder()
        
        if indexPath.section == 1 && indexPath.row == 1 {
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 && indexPath.row == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath.section == 1 && indexPath.row == 2 {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        return super.tableView(tableView,
                               indentationLevelForRowAt: newIndexPath)
    }

    // MARK: Actions
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.addOrEditItemViewControllerDidCancel(self)
    }
    
    @IBAction func done(_ sender: Any) {
        
        if let item = itemToEdit {
            item.text = newItemTextField.text!
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = dueDate
            item.scheduleNotification()
            
            delegate?.addOrEditItemViewController(self, didFinishEditing: item)
        } else {
            if let text = newItemTextField.text {
                let item = ChecklistItem(itemText: text, checkmarkChecked: false)
                item.shouldRemind = shouldRemindSwitch.isOn
                item.dueDate = dueDate
                item.scheduleNotification()
                
                delegate?.addOrEditItemViewController(self, didFinishAdding: item)
            }
        }
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        dueDate = (sender as! UIDatePicker).date
        updateDueDateLabel()
    }
    
    @IBAction func touchedBackground(sender: Any) {
       
        
        
    }
    
    @IBAction func shouldRemindToggled(_ sender: UISwitch) {
        newItemTextField.resignFirstResponder()
        
        if shouldRemindSwitch.isOn {
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound]) {
                    granted, error in /* do nothing */
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

protocol AddOrEditItemViewControllerDelegate: class {
    
    func addOrEditItemViewControllerDidCancel(_ controller: AddOrEditItemViewController)
    func addOrEditItemViewController(_ controller: AddOrEditItemViewController, didFinishAdding item: ChecklistItem)
    func addOrEditItemViewController(_ controller: AddOrEditItemViewController, didFinishEditing item: ChecklistItem)
}
