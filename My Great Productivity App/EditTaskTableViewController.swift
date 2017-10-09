//
//  CreateTaskTableViewController.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 2/3/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EditTaskTableViewController:  UITableViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var durationPicker: UIDatePicker!
    
    @IBOutlet weak var priorityPicker: PriorityPickerView!
    
    @IBOutlet weak var pointsPicker: PointsPickerView!
    
    @IBOutlet weak var notes: UITextView!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var priorityLabel: UILabel!
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var colorPicker: ColorPickerView!
    
    @IBOutlet weak var colorLabel: UILabel!
    
    @IBOutlet weak var colorCell: UITableViewCell!
    
    @IBOutlet weak var amountDoneLabel: UILabel!
    
    @IBOutlet weak var groupLabel: UILabel!
    
    @IBOutlet weak var amountDonePicker: AmountDonePicker!
    
    @IBOutlet weak var groupsPicker: GroupsPicker!
    
    @IBOutlet weak var amountDoneTitle: UILabel!
    
    @IBOutlet weak var timeTitle: UILabel!
    
    @IBOutlet weak var dueDateX: UIButton!
    
    @IBOutlet weak var timeX: UIButton!
    
    @IBOutlet weak var durationX: UIButton!
    
    @IBOutlet weak var pointsX: UIButton!
    
    @IBOutlet weak var priorityX: UIButton!
    
    @IBOutlet weak var amountDoneX: UIButton!
    
    @IBOutlet weak var subtasksTableView: TasksTableViewController!
    
    @IBOutlet weak var sortByLabel: UILabel!
    
    @IBOutlet weak var sortByPicker: SortPicker!
    
    @IBOutlet weak var repeatLabel: UILabel!
    
    @IBOutlet weak var repeatTitle: UILabel!
    
    let expandedH: CGFloat = 200
    let regularH: CGFloat = 44
    let spaceH: CGFloat = 270
    let subtaskCellH: CGFloat = 480
    var selected: IndexPath?
    
    //task properties
    var timeDate: Date?
    var dueDate: Date?
    var duration: Int?
    var colorString: String = "White"
    var amountDoneType: String?
    var amountDone: Int?
    var gr: NSManagedObject?
    var repeatN: Int?
    
    @IBAction func doneButton(_ sender: Any) {
        saveTask()
        if curArr.count > 0{
            curArr.removeLast()
        }
        cur = curArr.last
        updateGroups()
        self.navigationController?.popViewController(animated: true)
        /*if (cur as! Group).group == nil { // parent is a list
         if let resultController = storyboard!.instantiateViewController(withIdentifier: "editListt") as? UINavigationController {
         present(resultController, animated: true, completion: nil)
         }
         }*/
    }
    override func viewWillAppear(_ animated: Bool) {
        if !(cur is Task) {
            self.navigationController?.popViewController(animated: false)
        }else{
            tableView.delegate = self
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateTaskTableViewController.dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
            setupPickerViews()
            setInitialValues()
            subtasksTableView.delegate = subtasksTableView
            subtasksTableView.dataSource = subtasksTableView
            subtasksTableView.arr = groups
            subtasksTableView.reloadData()
            subtasksTableView.parent = self
            showCompleted = false
            let longpress = UILongPressGestureRecognizer(target: subtasksTableView, action: Selector(("longPressGestureRecognized:")))
            subtasksTableView.addGestureRecognizer(longpress)
        }
    }
    
    func setupPickerViews() {
        //color
        colorPicker.parent = self
        colorPicker.dataSource = colorPicker
        colorPicker.delegate = colorPicker
        colorPicker.reloadAllComponents()
        //priority
        priorityPicker.parent = self
        priorityPicker.dataSource = priorityPicker
        priorityPicker.delegate = priorityPicker
        priorityPicker.reloadAllComponents()
        //points
        pointsPicker.parent = self
        pointsPicker.dataSource = pointsPicker
        pointsPicker.delegate = pointsPicker
        pointsPicker.reloadAllComponents()
        //amount done
        amountDonePicker.parent = self
        amountDonePicker.dataSource = amountDonePicker
        amountDonePicker.delegate = amountDonePicker
        amountDonePicker.reloadAllComponents()
        //group
        groupsPicker.parent = self
        groupsPicker.dataSource = groupsPicker
        groupsPicker.delegate = groupsPicker
        groupsPicker.setupArr()
        groupsPicker.reloadAllComponents()
        //sort by
        sortByPicker.parent = self
        sortByPicker.dataSource = sortByPicker
        sortByPicker.delegate = sortByPicker
        sortByPicker.reloadAllComponents()
        //others
        dueDatePicker?.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)
        timePicker?.addTarget(self, action: #selector(timePickerChanged(sender:)), for: .valueChanged)
        durationPicker?.addTarget(self, action: #selector(durationPickerChanged(sender:)), for: .valueChanged)
    }
    
    func setInitialValues() {
        let task = cur as! Task
        nameTextField.text = task.name
        //subtasksTableView.arr = Array(task.tasks!) as! [NSManagedObject]
        
        if let managedContext = getManagedContext() {
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "List")
            let predicate = NSPredicate(format: "name = %@", argumentArray: [task.name!])
            fetchRequest.predicate = predicate
            
            do {
                subtasksTableView.arr = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            if task.due != nil {
                dueDateLabel.text = formatDate(date: task.due! as Date)
                dueDate = task.due as Date?
                dueDateX.isHidden = false
                dueDatePicker.setDate(task.due! as Date, animated: false)
                if task.time == 1 {
                    timeLabel.text = formatTime(date: task.due! as Date)
                    timeDate = task.due as Date?
                    timeX.isHidden = false
                    timePicker.setDate(task.due! as Date, animated: false)
                }
            } else {
                timeTitle.textColor = UIColor.lightGray
                repeatTitle.textColor = UIColor.lightGray
            }
            if task.duration != 0 {
                durationLabel.text = formatDuration(duration: Int(task.duration))
                durationX.isHidden = false
            }
            if task.points != 0 {
                pointsPicker.selectRow(Int(task.points) - 1, inComponent: 0, animated: false)
                pointsLabel.text = String(task.points)
                pointsX.isHidden = false
            }
            if task.priority != nil {
                let index = task.priority?.index((task.priority?.startIndex)!, offsetBy: 1)
                let s = (task.priority?.substring(to: index!))!
                //let index2 = task.priority?.index((task.priority?.startIndex)!, offsetBy: 1)
                let s2 = (task.priority?.substring(from: index!))!
                priorityPicker.selectRow(priorityPicker.arr[0].index(of:s)!, inComponent: 0, animated: false)
                priorityPicker.selectRow( Int(s2)! - 1, inComponent: 1, animated: false)
                priorityLabel.text = task.priority
                priorityX.isHidden = false
            }
            colorPicker.selectRow(colorsArray.index(of: (cur as! Group).color!)!, inComponent: 0, animated: false)
            updateColor(row: colorsArray.index(of: (cur as! Group).color!)!)
            if task.notes != nil {
                notes.text = task.notes
            }
            if task.amountDoneType != nil {
                amountDoneType = task.amountDoneType
                amountDone = Int(task.amountDone)
                if  task.amountDoneType == "Duration" {
                    amountDoneLabel.text = formatDuration(duration: Int(task.amountDone))
                    amountDonePicker.selectRow(Int(task.amountDone), inComponent: 1, animated: false)
                } else if task.amountDoneType == "Points"{
                    if task.duration == 0 {
                        amountDonePicker.selectRow(0, inComponent: 0, animated: false)
                    } else {
                        amountDonePicker.selectRow(1, inComponent: 0, animated: false)
                    }
                    amountDonePicker.reloadAllComponents()
                    amountDonePicker.selectRow(Int(task.amountDone), inComponent: 1, animated: false)
                    amountDoneLabel.text =  String(task.amountDone) + " Points"
                }
                amountDoneX.isHidden = false
            }
            
            if task.group != nil {
                groupLabel.text = task.group?.name
            }
            
            if task.repeatN != 0 {
                repeatN = Int(task.repeatN)
                repeatLabel.text = formatRepeat(num: repeatN!)
            }
        }
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        print("---------------bef-----------")
        print(curArr)
        if curArr.count > 0{
            curArr.removeLast()
        }
        print("--------------aft------------")
        print(curArr)
        cur = curArr.last
        updateGroups()
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func dueDateXButton(_ sender: Any) {
        dueDate = nil
        dueDateLabel.text = ""
        timeDate = nil
        timeLabel.text = ""
        dueDateX.isHidden = true
        timeX.isHidden = true
        timeTitle.textColor = UIColor.lightGray
        repeatN = 0
        repeatLabel.text = ""
        repeatTitle.textColor = UIColor.lightGray
        selected = nil
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func timeXButton(_ sender: Any) {
        timeDate = nil
        timeLabel.text = ""
        timeX.isHidden = true
        selected = nil
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func durationXButton(_ sender: Any) {
        duration = nil
        durationLabel.text = ""
        durationX.isHidden = true
        selected = nil
        let task = cur as! Task
        task.duration = 0
        if amountDoneType == "Duration" {
            amountDoneX.isHidden = true
            amountDoneType = nil
            amountDone = nil
            amountDoneLabel.text = ""
            task.amountDoneType = nil
            task.amountDone = 0
            amountDonePicker.reloadAllComponents()
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func pointsXButton(_ sender: Any) {
        pointsLabel.text = ""
        pointsX.isHidden = true
        selected = nil
        let task = cur as! Task
        task.points = 0
        if amountDoneType == "Points" {
            amountDoneX.isHidden = true
            amountDoneType = nil
            amountDone = nil
            amountDoneLabel.text = ""
            task.amountDoneType = nil
            task.amountDone = 0
            amountDonePicker.reloadAllComponents()
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func priorityXButton(_ sender: Any) {
        priorityLabel.text = ""
        priorityX.isHidden = true
        selected = nil
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func amountDoneXButton(_ sender: Any) {
        amountDoneX.isHidden = true
        amountDoneType = nil
        amountDone = nil
        selected = nil
        amountDoneLabel.text = ""
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func showCompletedSwitch(_ sender: Any) {
        showCompleted = !showCompleted
        updateGroups(showComp: showCompleted)
        subtasksTableView.arr = groups
        subtasksTableView.reloadData()
    }
    
    @IBAction func seeGroupButton(_ sender: Any) {
        cur = (cur as! Task).group
        curArr.append(cur!)
        if cur is Task {
            let storyboard = UIStoryboard(name: "Tasks", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "EditTask")
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Tasks", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "editList")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func updateColor (row: Int) {
        colorCell.backgroundColor = color(color: colorsArray[row])
        self.colorString = colorsArray[row]
    }
    
    override func updatePriority(priority: String) {
        self.priorityLabel.text = priority
        priorityX.isHidden = false
    }
    
    override func updatePoints(points: Int) {
        self.pointsLabel.text = String(points)
        amountDoneTitle.textColor = UIColor.black
        (cur as! Task).points = Int64(points)
        pointsX.isHidden = false
        amountDonePicker.reloadAllComponents()
    }
    
    override func updateGroup(group: NSManagedObject) {
        groupLabel.text = (group as! Group).name
        gr = group
    }
    
    override func updateRepeat(num: Int) {
        repeatN = num
        repeatLabel.text = formatRepeat(num: num)
    }
    
    override func updateAmountDone(type: String, amount: Int) {
        amountDoneType = type
        if amountDonePicker.numberOfComponents != 1{
            amountDonePicker.reloadComponent(1)
            amountDone = amountDonePicker.selectedRow(inComponent: 1) + 1
        }
        amountDoneX.isHidden = false
        if type == "Duration" {
            amountDoneLabel.text = formatDuration(duration: amountDonePicker.selectedRow(inComponent: 1)+1)
        } else if type == "Points"{
            amountDoneLabel.text =  String(amountDonePicker.selectedRow(inComponent: 1)+1) + " Points"
        } else if type == "N of Subtasks"{
            amountDoneLabel.text = "Number of Subtasks"
        } else if type == "Subt Points"{
            amountDoneLabel.text = "Subtask Points"
        } else if type == "Subt Duration"{
            amountDoneLabel.text = "Subtask Duration"
        }
    }
    
    override func updateSort(sortBy: String) {
        sortByLabel.text = sortBy
        switch sortBy {
        case "Due Date":
            sortGroupsBy(sortBy: NSSortDescriptor.init(key: "due", ascending: true))
        case "Priority":
            sortGroupsBy(sortBy: NSSortDescriptor.init(key: "priority", ascending: true))
        case "Duration":
            sortGroupsBy(sortBy: NSSortDescriptor.init(key: "duration", ascending: true))
        case "Points":
            sortGroupsBy(sortBy: NSSortDescriptor.init(key: "points", ascending: true))
        default:
            sortGroupsBy(sortBy: NSSortDescriptor.init(key: "name", ascending: true))
        }
        subtasksTableView.arr = groups
        subtasksTableView.reloadData()
        for i in 0..<groups.count {
            (groups[i] as? Group)?.index = Int64(i)
        }
    }
    
    func datePickerChanged(sender: UIDatePicker) {
        dueDateLabel.text = formatDate(date: sender.date)
        dueDate = sender.date
        timeTitle.textColor = UIColor.black
        repeatTitle.textColor = UIColor.black
        dueDateX.isHidden = false
    }
    
    func timePickerChanged(sender: UIDatePicker) {
        timeLabel.text = formatTime(date: sender.date)
        timeDate = sender.date
        timeX.isHidden = false
    }
    
    func durationPickerChanged(sender: UIDatePicker) {
        duration = getDuration(date: sender.date)
        durationLabel.text = String(formatDuration(duration: sender.date))
        amountDoneTitle.textColor = UIColor.black
        (cur as! Task).duration = Int64(getDuration(date: sender.date))
        amountDonePicker.reloadAllComponents()
        durationX.isHidden = false
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func setPickerInitValue() {
        let dateIndex = IndexPath(item: 0, section: 2)
        let timeIndex = IndexPath(item: 1, section: 2)
        let durationIndex = IndexPath(item: 0, section: 3)
        let pointsIndex = IndexPath(item: 1, section: 3)
        let priorityIndex = IndexPath(item: 0, section: 4)
        let amountDoneIndex = IndexPath(item: 0, section: 5)
        switch selected! {
        case dateIndex:
            if dueDateLabel.text != "" {
                break
            }
            dueDateLabel.text = formatDate(date: dueDatePicker.date)
            dueDate = dueDatePicker.date
            timeTitle.textColor = UIColor.black
            repeatTitle.textColor = UIColor.black
            self.dueDateX.isHidden = false
        case timeIndex:
            if timeLabel.text != ""{
                break
            }
            timeLabel.text = formatTime(date: timePicker.date)
            timeDate = timePicker.date
            self.timeX.isHidden = false
        case durationIndex:
            if durationLabel.text != ""{
                break
            }
            duration = getDuration(date: durationPicker.date)
            (cur as! Task).duration = Int64(duration!)
            durationLabel.text = String(formatDuration(duration: durationPicker.date))
            self.durationX.isHidden = false
        case pointsIndex:
            if pointsLabel.text != ""{
                break
            }
            updatePoints(points: pointsPicker.selectedRow(inComponent: 0) + 1)
        case priorityIndex:
            if priorityLabel.text != ""{
                break
            }
            updatePriority(priority: priorityPicker.arr[0][priorityPicker.selectedRow(inComponent: 0)] + priorityPicker.arr[1][priorityPicker.selectedRow(inComponent: 1)])
        case amountDoneIndex:
            var s = "Points"
            let row = amountDonePicker.selectedRow(inComponent: 0)
            if (cur as! Task).duration != 0 && row == 0{
                s = "Duration"
            }
            if (((cur as! Task).duration != 0 && (cur as! Task).points == 0) || ((cur as! Task).duration == 0 && (cur as! Task).points != 0)) && row == 1 {
                s = "N of Subtasks"
            }
            if row == 2 {
                s = "N of Subtasks"
            }
            
            if (cur as! Task).duration == 0 && (cur as! Task).duration == 0 {
                s = "N of Subtasks"
            }
            if amountDonePicker.numberOfComponents == 1 {
                updateAmountDone(type: s, amount: 0)
            } else {
                updateAmountDone(type: s, amount: amountDonePicker.selectedRow(inComponent: 1) + 1)
            }
        default: break
        }
    }
    
    func saveTask() {
        if nameTextField.text == "" {
            
        }else{
            
            if let managedContext = getManagedContext() {
                
                let task = cur as! Task
                
                task.name = nameTextField.text
                
                if timeDate != nil && dueDate != nil {
                    task.time = 1
                    task.due = combineDateWithTime(date: dueDate!, time: timeDate!) as NSDate!
                } else {
                    task.time = 0
                    if dueDate != nil {
                        task.due = dueDate as NSDate!
                    } else {
                        task.due = nil
                    }
                }
                
                if duration != nil {
                    task.duration = Int64(duration!)
                } else {
                    task.duration = 0
                }
                
                if priorityLabel.text != "" {
                    task.priority = priorityLabel.text
                } else {
                    task.priority = nil
                }
                
                if pointsLabel.text != nil && pointsLabel.text != "" {
                    task.points = Int64(pointsLabel.text!)!
                } else {
                    task.points = 0
                }
                
                task.notes = notes.text!
                task.color = colorString
                task.completed = 0
                
                if repeatN != nil {
                    task.repeatN = Int32(repeatN!)
                }
                
                if amountDoneType != nil {
                    task.amountDoneType = amountDoneType
                    if amountDone != nil {
                        task.amountDone = Int64(amountDone!)
                    }else{
                        task.amountDone = 0
                    }
                } else {
                    task.amountDoneType = nil
                    task.amountDone = 0
                }
                
                if gr != nil {
                    task.group = gr as! Group?
                }
                
                saveManagedContext(managedContext: managedContext)
            }
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repeatIndex = IndexPath(item: 2, section: 1)
        let createSubtaskIndex = IndexPath(item: 2, section: 0)
        if indexPath == repeatIndex {
            if dueDate != nil {
                performSegue(withIdentifier: "ShowRepeat", sender: self)
            }
            
        }
        if indexPath == createSubtaskIndex {
            performSegue(withIdentifier: "CreateSubtask", sender: self)
        }
        selected = indexPath
        tableView.beginUpdates()
        tableView.endUpdates()
        print(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let nameIndex = IndexPath(item: 0, section: 1)
        let notesIndex = IndexPath(item: 0, section: 6)
        let spaceIndex = IndexPath(item: 1, section: 6)
        let subtaskIndex = IndexPath(item: 3, section: 0)
        let subtasksIndex = IndexPath(item: 0, section: 0)
        let addSubtaskIndex = IndexPath(item: 2, section: 0)
        //let amountDoneIndex = IndexPath(item: 0, section: 5)
        let timeIndex = IndexPath(item: 1, section: 2)
        let repeatIndex = IndexPath(item: 2, section: 2)
        if indexPath == nameIndex || indexPath == subtasksIndex || indexPath == addSubtaskIndex  || indexPath == repeatIndex {
            return regularH
        } else if indexPath == notesIndex {
            return expandedH
        } else if indexPath == spaceIndex {
            return spaceH
        } else if indexPath == subtaskIndex {
            return subtaskCellH
        } else if indexPath == selected {
            if indexPath == timeIndex {
                if dueDate == nil {
                    return regularH
                }
            }
            setPickerInitValue()
            return expandedH
        }
        return 44
    }
    
    override func editTask(index: Int) {
        updateGroups()
        let storyboard = UIStoryboard(name: "Tasks", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditTask")
        self.navigationController?.pushViewController(vc, animated: true)
        //tableView.reloadData()
    }
}
