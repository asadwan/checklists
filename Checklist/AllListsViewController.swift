//
//  AllListsTableViewController.swift
//  Checklists
//
//  Created by Abdullah Adwan on 5/27/17.
//  Copyright © 2017 Abdullah Adwan. All rights reserved.
//

import UIKit

class AllListsViewController: UITableViewController, AddOrEditListViewControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    var checklistDataModel: ChecklistsDataModel!
    
    // MARK: Initialization
  

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.delegate = self
        
        let index = checklistDataModel.indexOfSelectedChecklist
        if index >= 0 && index < checklistDataModel.lists.count {
            let checklist = checklistDataModel.lists[index]
            performSegue(withIdentifier: "ShowChecklist", sender: checklist)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Private Methods
    
    private func makeCell(for tableView: UITableView) -> UITableViewCell {
        let reusbaleCellIdentifier = "Cell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: reusbaleCellIdentifier) {
            return cell
        } else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: reusbaleCellIdentifier)
        }
        
    }
    
    private func addList(checklist: Checklist) {
        let newchecklistIndex = checklistDataModel.lists.count
        checklistDataModel.lists.append(checklist)
        checklistDataModel.sortChecklists()
        
        let indexPath = IndexPath(row: newchecklistIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    private func configureDetailTextLabel(for cell: UITableViewCell, at indexPath: IndexPath) {
        
        let listUncheckedItemsCount = checklistDataModel.lists[indexPath.row].countUncheckedItems()
        if checklistDataModel.lists[indexPath.row].items.isEmpty {
            cell.detailTextLabel!.text = "(No items)"
        } else if listUncheckedItemsCount == 0 {
            cell.detailTextLabel!.text = "All Done!"
        } else {
            cell.detailTextLabel!.text = "\(listUncheckedItemsCount) Remaining"
        }
        
        //print("fuck me")
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return checklistDataModel.lists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = makeCell(for: tableView)
        cell.textLabel!.text = checklistDataModel.lists[indexPath.row].name
        configureDetailTextLabel(for: cell, at: indexPath)
        cell.accessoryType = .detailDisclosureButton
        cell.imageView!.image = UIImage(named: checklistDataModel.lists[indexPath.row].iconName)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        checklistDataModel.indexOfSelectedChecklist = indexPath.row
        
        let checklist = checklistDataModel.lists[indexPath.row]
        performSegue(withIdentifier: "ShowChecklist", sender: checklist)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        checklistDataModel.lists.remove(at: indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .fade)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let navigationController = storyboard?.instantiateViewController(withIdentifier: "AddOrEditListNavigationController") as! UINavigationController
        
        let controller = navigationController.visibleViewController as! AddOrEditListViewController
        
        controller.delegate = self
        // controller.title = "Edit List"
        let checklist = checklistDataModel.lists[indexPath.row]
        controller.checklistToEdit = checklist
        
        present(navigationController, animated: true, completion: nil)
    }

    // MARK: AddOrEditListViewController Delegation
    
    func addOrEditListViewControllerDidCancel(_ controller: AddOrEditListViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addOrEditListViewController(_ controller: AddOrEditListViewController, didFinishAdding list: Checklist) {
        addList(checklist: list)
        dismiss(animated: true, completion: nil)
    }
    
    func addOrEditListViewController(_ controller: AddOrEditListViewController, didFinishEditing list: Checklist) {
        /*if let index = checklistDataModel.lists.index(of: list) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.textLabel?.text = list.name
            }
        }
        */
        checklistDataModel.sortChecklists()
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation Controller Delegation
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
            
        if viewController === self {
            checklistDataModel.indexOfSelectedChecklist = -1
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChecklist" {
            let controller = segue.destination as! ChecklistViewController
            if let checklist = sender as? Checklist {
                controller.title = checklist.name
                controller.checklist = checklist
            }
        } else if segue.identifier == "EditChecklist" {
            
        } else if segue.identifier == "AddChecklist" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! AddOrEditListViewController
            controller.title = "Add List"
            controller.delegate = self
        }
    }
    

}
