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

class CreateTaskTableViewController:  UITableViewController {
    
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
    
    @IBOutlet weak var timeTitle: UILabel!
    
    @IBOutlet weak var dueDateX: UIButton!
    
    @IBOutlet weak var timeX: UIButton!
    
    @IBOutlet weak var durationX: UIButton!
    
    @IBOutlet weak var pointsX: UIButton!
    
    @IBOutlet weak var priorityX: UIButton!
    
    @IBOutlet weak var repeatLabel: UILabel!
    
    @IBOutlet weak var repeatTitle: UILabel!
    
    @IBOutlet weak var groupLabel: UILabel!
    
    @IBOutlet weak var groupsPicker: GroupsPicker!
    
    @IBOutlet weak var amountDoneLabel: UILabel!
    
    @IBOutlet weak var amountDonePicker: AmountDonePicker!
    
    @IBOutlet weak var amountDoneX: UIButton!
    
    let expandedH: CGFloat = 200
    let regularH: CGFloat = 44
    let spaceH: CGFloat = 270
    var selected: IndexPath?
    var oldCur = cur
    
    //task properties
    var timeDate: Date?
    var dueDate: Date?
    var duration: Int?
    var colorString: String = "White"
    var repeatN: Int?
    var gr: NSManagedObject?
    var amountDoneType: String?
    var amountDone: Int?
    
    override func viewDidLoad() {
        tableView.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateTaskTableViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        timeTitle.textColor = UIColor.lightGray
        repeatTitle.textColor = UIColor.lightGray
        if (cur as! Group).name != "All" && (cur as! Group).name != "This Week" && (cur as! Group).name != "Today"  && (cur as! Group).name != "Overdue" {
            groupLabel.text = (cur as! Group).name
            gr = (cur as! Group)
        }
        if (cur as! Group).name == "Today" {
            let date =  Date()
            dueDateLabel.text = formatDate(date: date)
            dueDate = date
            dueDateX.isHidden = false
            dueDatePicker.setDate(date, animated: false)
        }
        groupsPicker.parent = self
        groupsPicker.dataSource = groupsPicker
        groupsPicker.delegate = groupsPicker
        groupsPicker.setupArrIncludingCur()
        groupsPicker.reloadAllComponents()
        oldCur = cur
        
        
        if let managedContext = getManagedContext() {
            
            let entity = NSEntityDescription.entity(forEntityName: "Task",
                                                    in: managedContext)!
            
            let task = NSManagedObject(entity: entity,
                                       insertInto: managedContext) as! Task
            cur = task
            setupPickerViews()
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
        //others
        dueDatePicker?.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)
        timePicker?.addTarget(self, action: #selector(timePickerChanged(sender:)), for: .valueChanged)
        durationPicker?.addTarget(self, action: #selector(durationPickerChanged(sender:)), for: .valueChanged)
    }
    
    @IBAction func dueDateXButton(_ sender: Any) {
        dueDate = nil
        dueDateLabel.text = ""
        timeDate = nil
        timeLabel.text = ""
        dueDateX.isHidden = true
        timeX.isHidden = true
        timeTitle.textColor = UIColor.lightGray
        repeatN = nil
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
    
    @IBAction func amountDoneXButoon(_ sender: Any) {
        amountDoneX.isHidden = true
        amountDoneType = nil
        amountDone = nil
        selected = nil
        amountDoneLabel.text = ""
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
    
    @IBAction func doneCreatingTask(_ sender: Any) {
        saveTask()
        updateGroups()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelCreateTask(_ sender: Any) {
        cur = oldCur
        if cur != nil {
            updateGroups()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func updateColor (row: Int) {
        colorCell.backgroundColor = color(color: colorsArray[row])
        self.colorString = colorsArray[row]
    }
    
    override func updatePriority(priority: String) {
        self.priorityLabel.text = priority
        self.priorityX.isHidden = false
    }
    
    override func updatePoints(points: Int) {
        self.pointsLabel.text = String(points)
        self.pointsX.isHidden = false
        (cur as! Task).points = Int64(points)
        amountDonePicker.reloadAllComponents()
    }
    
    override func updateGroup(group: NSManagedObject) {
        groupLabel.text = (group as! Group).name
        gr = group
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
    
    func datePickerChanged(sender: UIDatePicker) {
        dueDateLabel.text = formatDate(date: sender.date)
        dueDate = sender.date
        timeTitle.textColor = UIColor.black
        repeatTitle.textColor = UIColor.black
        self.dueDateX.isHidden = false
    }
    
    func timePickerChanged(sender: UIDatePicker) {
        timeLabel.text = formatTime(date: sender.date)
        timeDate = sender.date
        self.timeX.isHidden = false
    }
    
    func durationPickerChanged(sender: UIDatePicker) {
        duration = getDuration(date: sender.date)
        durationLabel.text = String(formatDuration(duration: sender.date))
        self.durationX.isHidden = false
        (cur as! Task).duration = Int64(getDuration(date: sender.date))
        amountDonePicker.reloadAllComponents()
    }
    
    func setPickerInitValue() {
        let dateIndex = IndexPath(item: 0, section: 1)
        let timeIndex = IndexPath(item: 1, section: 1)
        let durationIndex = IndexPath(item: 0, section: 2)
        let pointsIndex = IndexPath(item: 1, section: 2)
        let priorityIndex = IndexPath(item: 0, section: 3)
        //let groupIndex = IndexPath(item: 0, section: 4)
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
            if(row == 2) {
                s = "N of Subtasks"
            }
            
            if (cur as! Task).duration == 0 && (cur as! Task).duration == 0{
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
    
    override func updateRepeat(num: Int) {
        repeatN = num
        repeatLabel.text = formatRepeat(num: num)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func saveTask() {
        if nameTextField.text == "" {
            
        }else{
            
            if let managedContext = getManagedContext() {
                
                let task = cur as! Task
                cur = oldCur
                
                task.name = nameTextField.text
                if timeDate != nil && dueDate != nil {
                    task.time = 1
                    task.due = combineDateWithTime(date: dueDate!, time: timeDate!) as NSDate!
                    
                } else {
                    task.time = 0
                    if dueDate != nil {
                        task.due = dueDate as NSDate!
                    }
                }
                if duration != nil {
                    task.duration = Int64(duration!)
                }
                if(priorityLabel.text != "") {
                    task.priority = priorityLabel.text
                }
                if(pointsLabel.text != "") {
                    task.points = Int64(pointsLabel.text!)!
                }
                if(notes.text != "") {
                    task.notes = notes.text!
                }
                if repeatN != nil {
                    task.repeatN = Int32(repeatN!)
                }
                task.color = colorString
                var g = [NSManagedObject]()
                if gr != nil && (gr as! Group).name != "Today" && (gr as! Group).name != "This Week" && (gr as! Group).name != "Overdue" && (gr as! Group).name != "None"{
                    task.group = gr as! Group?
                } else {
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "List")
                    let predicate = NSPredicate(format: "name = %@", argumentArray: ["All"])
                    fetchRequest.predicate = predicate
                    do {
                        g = try managedContext.fetch(fetchRequest)
                    } catch let error as NSError {
                        print("Could not fetch. \(error), \(error.userInfo)")
                    }
                    task.group = g[0] as? Group
                }
                
                if amountDoneType != nil {
                    task.amountDoneType = amountDoneType
                    if amountDone != nil {
                        task.amountDone = Int64(amountDone!)
                    } else {
                        task.amountDone = 0
                    }
                } else {
                    task.amountDoneType = nil
                    task.amountDone = 0
                }
                
                task.completed = 0
                
                if saveManagedContext(managedContext: managedContext) {
                    groups.append(task)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRepeat" {
            if let colorViewController = segue.destination as? RepeatViewController {
                colorViewController.back = sender as! UIViewController?
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
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let nameIndex = IndexPath(item: 0, section: 0)
        let notesIndex = IndexPath(item: 0, section: 5)
        let spaceIndex = IndexPath(item: 1, section: 5)
        let timeIndex = IndexPath(item: 1, section: 1)
        let repeatIndex = IndexPath(item: 2, section: 1)
        if indexPath == nameIndex || indexPath == repeatIndex {
            return regularH
        } else if indexPath == notesIndex {
            return expandedH
        } else if indexPath == spaceIndex {
            return spaceH
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
    
}
