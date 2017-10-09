//
//  CreatePlanViewController.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 2/22/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CreatePlanViewController:  UITableViewController {
    
    @IBOutlet weak var startAtLabel: UILabel!
    
    @IBOutlet weak var startAtPicker: UIDatePicker!
    
    @IBOutlet weak var startAtXButton: UIButton!
    
    @IBOutlet weak var endAtLabel: UILabel!
    
    @IBOutlet weak var endAtPicker: UIDatePicker!
    
    @IBOutlet weak var endAtXButton: UIButton!
    
    @IBOutlet weak var breaksEveryLabel: UILabel!
    
    @IBOutlet weak var breaksEveryPicker: UIDatePicker!
    
    @IBOutlet weak var breaksEveryXButton: UIButton!
    
    @IBOutlet weak var breaksDurationLabel: UILabel!
    
    @IBOutlet weak var breaksDurationPicker: UIDatePicker!
    
    @IBOutlet weak var breaksDurationXButton: UIButton!
    
    @IBOutlet weak var orderByLabel: UILabel!
    
    @IBOutlet weak var orderByPicker: OrderByPicker!
    
    var selectedIndex: IndexPath?
    var thisPlan: Plan?
    
    //index for each cell
    let startAtIndex = IndexPath(item: 0, section: 0)
    let endAtIndex = IndexPath(item: 1, section: 0)
    let breakEveryIndex = IndexPath(item: 0, section: 1)
    let breakDurationIndex = IndexPath(item: 1, section: 1)
    let orderByIndex = IndexPath(item: 0, section: 2)
    
    override func viewDidAppear(_ animated: Bool) {
        setupPickers()
    }
    
    
    // MARK: - Setup
    func setupPickers() {
        
        orderByPicker.delegate = orderByPicker
        orderByPicker.dataSource = orderByPicker
        orderByPicker.parentVc = self
        orderByPicker.reloadAllComponents()
        orderByPicker.selectRow(4, inComponent: 0, animated: false)
        orderByLabel.text = orderByPicker.arr[4]
        
        startAtPicker?.addTarget(self, action: #selector(startAtPickerChanged(sender:)), for: .valueChanged)
        endAtPicker?.addTarget(self, action: #selector(endAtPickerChanged(sender:)), for: .valueChanged)
        breaksEveryPicker?.addTarget(self, action: #selector(breaksEveryPickerChanged(sender:)), for: .valueChanged)
        breaksDurationPicker?.addTarget(self, action: #selector(breaksDurationPickerChanged(sender:)), for: .valueChanged)
        
        startAtLabel.text = formatDate(date: startAtPicker.date)
    }
    
    //called when open a cell to set the initial picker value to the label
    func setUpPickerLabel() {
        switch selectedIndex! {
        case startAtIndex:
            if startAtLabel.text != ""{
                break
            }
            startAtLabel.text = formatTime(date: startAtPicker.date)
            self.startAtXButton.isHidden = false
        case endAtIndex:
            if endAtLabel.text != ""{
                break
            }
            endAtLabel.text = formatTime(date: endAtPicker.date)
            self.endAtXButton.isHidden = false
        case breakEveryIndex:
            if breaksEveryLabel.text != ""{
                break
            }
            breaksEveryLabel.text = String(formatDuration(duration: breaksEveryPicker.date))
            self.breaksEveryXButton.isHidden = false
        case breakDurationIndex:
            if breaksDurationLabel.text != ""{
                break
            }
            breaksDurationLabel.text = String(formatDuration(duration: breaksDurationPicker.date))
            self.breaksDurationXButton.isHidden = false
        default: break
        }
    }
    
    
    
    //MARK: - Picker changed
    func startAtPickerChanged(sender: UIDatePicker) {
        startAtLabel.text = formatTime(date: startAtPicker.date)
    }
    
    func endAtPickerChanged(sender: UIDatePicker) {
        endAtLabel.text = formatTime(date: endAtPicker.date)
    }
    
    func breaksEveryPickerChanged(sender: UIDatePicker) {
        breaksEveryLabel.text = String(formatDuration(duration: breaksEveryPicker.date))
    }
    
    func breaksDurationPickerChanged(sender: UIDatePicker) {
        breaksDurationLabel.text = String(formatDuration(duration: breaksDurationPicker.date))
    }
    
    override func updateOrderBy(row: Int) {
        orderByLabel.text = orderByPicker.arr[row]
    }
    
    
    
    // MARK: - X Buttons
    @IBAction func startAtXButton(_ sender: Any) {
        startAtXButton.isHidden = true
        startAtLabel.text = ""
    }
    
    @IBAction func endAtXButton(_ sender: Any) {
        endAtXButton.isHidden = true
        endAtLabel.text = ""
    }
    
    @IBAction func breaksEveryXButton(_ sender: Any) {
        breaksEveryXButton.isHidden = true
        breaksEveryLabel.text = ""
    }
    
    @IBAction func breaksDurationXButton(_ sender: Any) {
        breaksDurationXButton.isHidden = true
        breaksDurationLabel.text = ""
    }
    
    
    
    
    // MARK: - Bar buttons
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        savePlan()
    }
    
    
    
    
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex == indexPath {
            selectedIndex = nil
        } else {
            selectedIndex = indexPath
            setUpPickerLabel()
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        print(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selectedIndex {
            return 200
        }
        return 44
    }
    
    
    
    // MARK - Save
    func savePlan() {
        if let managedContext = getManagedContext() {
            let entity = NSEntityDescription.entity(forEntityName: "Plan",
                                                    in: managedContext)!
            let plan = NSManagedObject(entity: entity,
                                       insertInto: managedContext) as! Plan
            plan.day = Date() as NSDate
            if startAtLabel.text != "" {
                plan.startTime = startAtPicker.date as NSDate
            }
            if endAtLabel.text != "" {
                plan.endTime = endAtPicker.date as NSDate
            }
            if breaksEveryLabel.text != "" {
                plan.breakEvery = Int64(getDuration(date: breaksEveryPicker.date))
            }
            if breaksDurationLabel.text != "" {
                plan.breakDuration = Int64(getDuration(date: breaksDurationPicker.date))
            }
            
            plan.orderBy = orderByLabel.text
            
            saveManagedContext(managedContext: managedContext)
            thisPlan = plan
            addTasksTo(plan: plan)
        }
    }
    
    
    func addTasksTo(plan: Plan) {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        
        //get tasks on this day that were not yet completed
        var tasksToday: [NSManagedObject] = []
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: plan.startTime! as Date) // eg. 2016-10-10 00:00:00
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
        components.day! += 1
        let dateTo = calendar.date(from: components)! // eg. 2016-10-11 00:00:00
        // Set predicate as date being today's date
        let predicate = NSPredicate(format: "(%@ <= due) AND (due < %@) AND completed == 0", argumentArray: [dateFrom, dateTo])
        fetchRequest.predicate = predicate
        
        
        
        //sort them by due date
        //tasks that have a due time come first
        let sortDescriptor0 =  NSSortDescriptor.init(key: "time", ascending: false)
        //then sorted by due date and time
        let sortDescriptor1 =  NSSortDescriptor.init(key: "due", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor0, sortDescriptor1]
        
        
        
        fetchGroups(fetchRequest: fetchRequest)
        
        //set plan index to tasks
        for i in 0..<tasksToday.count {
            (tasksToday[i] as! Task).planIndex = Int64(i)
        }
        
        //add tasks to the plan
        plan.planIten = NSSet(array: tasksToday)
        if plan.endTime == nil {
            plan.endTime =  calculateEndTime(startTime: plan.startTime! as Date, tasks: tasksToday as! [Task]) as NSDate
        }
        performSegue(withIdentifier: "adjustPlan", sender: tasksToday)
    }
    
    func calculateEndTime(startTime: Date, tasks: [Task]) -> Date{
        var totalDuration = 0
        for task in tasks {
            totalDuration += Int(task.duration)
        }
        let calendar = NSCalendar.current
        let endTime = calendar.date(byAdding: .minute, value: totalDuration, to: startTime)
        return endTime!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let adjustPlanViewController = segue.destination as? AdjustPlanViewController {
            adjustPlanViewController.planTasks = sender as! [Task]!
            adjustPlanViewController.curPlan = thisPlan
        }
    }
}
