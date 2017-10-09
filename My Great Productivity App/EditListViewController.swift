//
//  EditListViewController.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 2/1/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EditListViewController: UITableViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var colorCell: UITableViewCell!
    
    @IBOutlet weak var colorPicker: ColorPickerView!
    
    @IBOutlet weak var subtasksTableView: TasksTableViewController!
    
    @IBOutlet weak var addTaskCell: UITableViewCell!
    
    @IBOutlet weak var sortByLabel: UILabel!
    
    @IBOutlet weak var sortPicker: SortPicker!
    
    @IBOutlet weak var groupPicker: GroupsPicker!
    
    @IBOutlet weak var groupLabel: UILabel!
    
    let colorCellExpandedHeight = 200
    let colorCellRegularHeight = 44
    var colorCelllExpandedIndex: IndexPath? = nil
    var open = false
    var gr: Group?
    
    override func viewWillAppear(_ animated: Bool) {
        if cur == nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            let group = cur as! Group
            
            if group.name == "Today"{
                performSegue(withIdentifier: "ShowToday", sender: self)
            }
            
            if group.name == "Overdue"{
                performSegue(withIdentifier: "ShowOverdue", sender: self)
            }
            
            nameTextField.text = group.name
            
            colorCell.backgroundColor = color(color: group.color!)
            colorPicker.delegate = colorPicker
            colorPicker.dataSource = colorPicker
            colorPicker.reloadAllComponents()
            colorPicker.selectRow(colorsArray.index(of: (cur as! Group).color!)!, inComponent: 0, animated: false)
            colorPicker.parent = self
            
            showCompleted = false
            
            groupPicker.selectRow(groupPicker.arr.count - 1, inComponent: 0, animated: false)
            
            //sort by picker
            sortPicker.parent = self
            sortPicker.dataSource = sortPicker
            sortPicker.delegate = sortPicker
            sortPicker.reloadAllComponents()
            
            showCompleted = false
            updateGroups(showComp: showCompleted)
            
            
            subtasksTableView.delegate = subtasksTableView
            subtasksTableView.dataSource = subtasksTableView
            subtasksTableView.parent = self
            subtasksTableView.arr = groups
            subtasksTableView.reloadData()
            
            groupPicker.setupArr()
            groupPicker.delegate = groupPicker
            groupPicker.dataSource = groupPicker
            groupPicker.reloadAllComponents()
            groupPicker.parent = self
            
            let longpress = UILongPressGestureRecognizer(target: subtasksTableView, action: Selector(("longPressGestureRecognized:")))
            subtasksTableView.addGestureRecognizer(longpress)
        }
        
    }
    
    @IBAction func showCompleteSwitch(_ sender: Any) {
        showCompleted = !showCompleted
        updateGroups(showComp: showCompleted)
        subtasksTableView.arr = groups
        subtasksTableView.reloadData()
    }
    
    @IBAction func doneButton(_ sender: Any) {
        saveList()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func groupXButton(_ sender: Any) {
        gr = nil
        groupLabel.text = ""
    }
    
    @IBAction func backButton(_ sender: Any) {
        if curArr.count > 0 {
            curArr.removeLast()
        }
        cur = curArr.last
        if cur != nil {
            updateGroups()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //When done button clicked -> save
        if segue.identifier == "DoneEditingList" {
            saveList()
        }
    }
    
    override func updateSort(sortBy: String) {
        print(groups)
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
        print(groups)
        subtasksTableView.arr = groups
        subtasksTableView.reloadData()
        for i in 0..<groups.count {
            (groups[i] as? Group)?.index = Int64(i)
        }
    }
    
    func saveList() {
        if nameTextField.text != "" {
            (cur as! Group).name = nameTextField.text!
            (cur as! Group).color = colorsArray[colorPicker.selectedRow(inComponent: 0)]
        }
        
        if let managedContext = getManagedContext() {
            if gr != nil{
                let entity = NSEntityDescription.entity(forEntityName: "Task",
                                                        in: managedContext)!
                let task = NSManagedObject(entity: entity,
                                           insertInto: managedContext) as! Task
                task.name = (cur as! Group).name
                task.color = (cur as! Group).color
                task.group = gr
                managedContext.delete(cur!)
                cur = task
                updateGroups()
            }
            
            saveManagedContext(managedContext: managedContext)
        }
    }
    
    //Set cell color -> called when picker has changed
    override func updateColor (row: Int) {
        colorCell.backgroundColor = color(color: colorsArray[row])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        let i1 = NSIndexPath(item: 1, section: 0)
        let groupIndex = IndexPath(item: 2, section: 0)
        let i3 = IndexPath(item: 1, section: 1)
        if indexPath == i3 {
            open = !open
            tableView.beginUpdates()
            tableView.endUpdates()
        } else {
            if open {
                open = false
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
        let addTaskIndex = NSIndexPath(item: 2, section: 1)
        if colorCelllExpandedIndex != nil{
            //let prev = colorCelllExpandedIndex
            colorCelllExpandedIndex = nil
            //tableView.reloadRows(at: [prev!], with: .automatic)
            //tableView.reloadData()
            tableView.beginUpdates()
            tableView.endUpdates()
        } else if indexPath == i1 as IndexPath || indexPath == groupIndex {
            colorCelllExpandedIndex = indexPath
            //colorCell.frame.size.height = CGFloat(colorCellExpandedHeight)
            //tableView.reloadData()
            tableView.beginUpdates()
            tableView.endUpdates()
            //tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            //tableView.reloadRows(at: [colorCelllExpandedIndex!], with: .automatic)
        } else if indexPath == addTaskIndex as IndexPath  && (cur as! Group).name != "This Week"{
            performSegue(withIdentifier: "ShowCreateTask", sender: self)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let i1 = NSIndexPath(item: 1, section: 0)//color
        let groupIndex = IndexPath(item: 2, section: 0)
        let i3 = NSIndexPath(item: 1, section: 1)
        let i2 = NSIndexPath(item: 3, section: 1)
        if indexPath == colorCelllExpandedIndex {
            
            return CGFloat(colorCellExpandedHeight)
        } else {
            if indexPath == i1 as IndexPath || indexPath == groupIndex{
                return CGFloat(colorCellRegularHeight)
            }
            if indexPath == i2 as IndexPath {
                return 356
            }
            if indexPath == i3 as IndexPath  && open{
                return 200
            }
        }
        return UITableViewAutomaticDimension
    }
    
    override func editTask(index: Int) {
        updateGroups()
        performSegue(withIdentifier: "ShowEditTask", sender: self)
    }
    
    override func updateGroup(group: NSManagedObject) {
        groupLabel.text = (group as! Group).name
        gr = group as? Group
    }
    
}
