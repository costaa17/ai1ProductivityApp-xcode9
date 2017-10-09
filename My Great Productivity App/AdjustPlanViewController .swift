//
//  AdjustPlanViewController .swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 2/28/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AdjustPlanViewController:  UIViewController {
    
    @IBOutlet weak var tableView: PlanTaskTableView!
    
    @IBOutlet weak var addBreakButton: UIBarButtonItem!
    
    @IBOutlet weak var breakDurationStepper: UIStepper!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    
    var planTasks: [Task]?
    var addTask: Task?
    var curPlan: Plan?
    
    //MARK: - Setup
    override func viewDidLoad() {
        groups = planTasks!
        tableView.arr = planTasks!
        tableView.delegate = tableView
        tableView.dataSource = tableView
        tableView.parent = self
        tableView.reloadData()
        let longpress = UILongPressGestureRecognizer(target: tableView, action: Selector(("longPressGestureRecognized:")))
        tableView.addGestureRecognizer(longpress)
        breakDurationStepper.value = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        groups = planTasks!
        tableView.arr = planTasks!
        
        //add new task to the plan
        if addTask != nil {
            addTask?.plan = curPlan
            planTasks?.append(addTask!)
            groups = planTasks!
            tableView.arr = planTasks!
            curPlan?.planIten = NSSet(array: planTasks!)
            let calendar = NSCalendar.current
            let endTime = calendar.date(byAdding: .minute, value: Int(addTask!.duration), to: curPlan!.endTime! as Date)
            curPlan?.endTime = endTime as NSDate?
        }
        endTimeLabel.text = "End time: " + formatTime(date: curPlan!.endTime! as Date)
        tableView.reloadData()
    }
    
    //MARK: - Breaks
    @IBAction func breakDurationStepper(_ sender: UIStepper) {
        addBreakButton.title = "Add " + formatDuration(duration: Int(sender.value)) + " break"
    }
    
    @IBAction func addBreakButton(_ sender: Any) {
        
        if let managedContext = getManagedContext() {
            
            let entity = NSEntityDescription.entity(forEntityName: "Break",
                                                    in: managedContext)!
            
            let breakEntity = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as! Break
            breakEntity.duration = Int64(breakDurationStepper.value)
            
            breakEntity.name = "Break"
            
            planTasks!.append(breakEntity)
            groups = planTasks!
            tableView.arr = planTasks!
            
            let calendar = NSCalendar.current
            let endTime = calendar.date(byAdding: .minute, value: Int(breakDurationStepper.value), to: curPlan!.endTime! as Date)
            curPlan?.endTime = endTime as NSDate?
            endTimeLabel.text = "End time: " + formatTime(date: curPlan!.endTime! as Date)
            tableView.reloadData()
            
            saveManagedContext(managedContext: managedContext)
            
            tableView.reloadData()
        }
    }
    
    //MARK: - add tasks
    @IBAction func addTaskButton(_ sender: Any) {
        performSegue(withIdentifier: "addExistingTask", sender: self)
    }
    
    @IBAction func addNewTaskButton(_ sender: Any) {
    }
    
    
    //MARK: - done
    @IBAction func doneButton(_ sender: Any) {
        planTasks = tableView.arr as? [Task]
        //record order of the tasks
        for i in 0..<planTasks!.count {
            planTasks![i].planIndex = Int64(i)
        }
        //save plan - update the tasks
        curPlan?.planIten = NSSet(array: planTasks!)
        self.navigationController?.dismiss(animated: true, completion: nil)
        /*guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
         return
         }
         
         let managedContext = appDelegate.persistentContainer.viewContext
         do {
         let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PlanIten")
         
         let predicate = NSPredicate(format: "plan == %@", argumentArray: [curPlan!])
         fetchRequest.predicate = predicate
         //let ts = try managedContext.fetch(fetchRequest)
         try managedContext.save()
         } catch let error as NSError {
         print("Could not save. \(error), \(error.userInfo)")
         }*/
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let adjustPlanViewController = segue.destination as? ChoseTaskViewController {
            adjustPlanViewController.parentVC = sender as? AdjustPlanViewController
            adjustPlanViewController.thisPlan = curPlan
        }
    }
}
