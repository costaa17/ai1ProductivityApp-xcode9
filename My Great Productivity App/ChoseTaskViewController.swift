//
//  ChoseTaskViewController.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 3/5/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ChoseTaskViewController: UITableViewController {
    
    @IBOutlet weak var tasksTableView: UITableView!
    
    @IBOutlet weak var sortByLabel: UILabel!
    
    @IBOutlet weak var sortByPicker: SortPicker!
    
    var parentVC: AdjustPlanViewController?
    var parentVC2: NowViewController?
    var selected: IndexPath?
    let selTaskData = SelectTaskTableViewData()
    var thisPlan: Plan?

    override func didMove(toParentViewController parent: UIViewController?) {
        
        tableView.delegate = self
        tableView.reloadData()
        
        tasksTableView.delegate = selTaskData
        tasksTableView.dataSource = selTaskData
        selTaskData.parentVC = self
        tasksTableView.reloadData()
        
        sortByPicker.parent = self
        sortByPicker.dataSource = sortByPicker
        sortByPicker.delegate = sortByPicker
        sortByPicker.reloadAllComponents()
        
        // get all tasks by loading the "All" list
        
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "List")
        let predicate = NSPredicate(format: "name = %@", argumentArray: ["All"])
        fetchRequest.predicate = predicate
        
        fetchGroups(fetchRequest: fetchRequest)
        
        cur = groups[0] //All
        showCompleted = false
        
        // filter only tasks that are not yet in this plan
        updateGroupsWithPred(pred: NSPredicate(format: "plan == nil || plan != %@", argumentArray: [thisPlan!]))
        tasksTableView.reloadData()
    }
    
    override func updateSort(sortBy: String) {
        sortByLabel.text = sortBy
        switch sortBy {
        case "Due date":
            sortGroupsBy(sortBy: NSSortDescriptor.init(key: "due", ascending: true))
        case "Priority":
            sortGroupsBy(sortBy: NSSortDescriptor.init(key: "priority", ascending: true))
        case "Duration":
            sortGroupsBy(sortBy: NSSortDescriptor.init(key: "duration", ascending: false))
        case "Points":
            sortGroupsBy(sortBy: NSSortDescriptor.init(key: "points", ascending: false))
        default:
            sortGroupsBy(sortBy: NSSortDescriptor.init(key: "name", ascending: true))
        }
        tasksTableView.reloadData()
        for i in 0..<groups.count {
            (groups[i] as? Group)?.index = Int64(i)
        }
    }
    
    // MARK: - Table View
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sortIn = IndexPath(item: 0, section: 0)
        curArr.append(cur!)
        if indexPath == sortIn {
            if selected == nil {
                selected = indexPath
            }else{
                selected = nil
            }
        }else{
            selected = nil
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func choseTask(task: Task) {
        parentVC?.addTask = task
        parentVC2?.addTask = task
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selected {
            return 200
        }
        if indexPath == IndexPath(item: 1, section: 0) {
            return 559
        }
        return 44
    }
    @IBAction func backButton(_ sender: Any) {
        parentVC?.addTask = nil
        self.navigationController?.popViewController(animated: true)
    }
}
