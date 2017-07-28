//
//  AddOrEditListViewController.swift
//  Checklists
//
//  Created by Abdullah Adwan on 5/27/17.
//  Copyright © 2017 Abdullah Adwan. All rights reserved.
//

import UIKit

class AddOrEditListViewController: UITableViewController, UITextFieldDelegate, IconPickerViewControllerDelegate {
    
    // MARK: Properties
    
    weak var delegate: AddOrEditListViewControllerDelegate!
    var checklistToEdit: Checklist?
    var iconName = "Folder"
    
    
    @IBOutlet weak var listNameTextField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var iconImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let list = checklistToEdit {
            title = "Edit Checklist"
            listNameTextField.text = list.name
            doneButton.isEnabled = true
            iconName = list.iconName
        }
        
        iconImageView.image = UIImage(named: iconName)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listNameTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Actions
    
    @IBAction func done(_ sender: Any) {
        if let list = checklistToEdit {
            list.name = listNameTextField.text!
            list.iconName = iconName
            delegate?.addOrEditListViewController(self, didFinishEditing: list)
        } else {
            let newChecklist = Checklist(listName: listNameTextField.text!, iconName: iconName)
            delegate.addOrEditListViewController(self, didFinishAdding: newChecklist)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.addOrEditListViewControllerDidCancel(self)
    }
    
    // MARK: Table view data source
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == 1 {
            return indexPath
        } else {
        return nil
        }
    }
    
    
    // MARK: newListTextField delegation
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = listNameTextField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString

        doneButton.isEnabled = (newText.length > 0)
        
        return true
    }
    
    // MARK: Icon Picker Delegation
    
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String) {
        self.iconName = iconName
        iconImageView.image = UIImage(named: iconName)
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IconPicker" {
            let controller = segue.destination as! IconPickerViewController
            controller.delegate = self
        }
    }
    
}



protocol AddOrEditListViewControllerDelegate: class {
    
    func addOrEditListViewControllerDidCancel(_ controller: AddOrEditListViewController)
    func addOrEditListViewController(_ controller: AddOrEditListViewController, didFinishAdding list: Checklist)
    func addOrEditListViewController(_ controller: AddOrEditListViewController, didFinishEditing list: Checklist)
}
