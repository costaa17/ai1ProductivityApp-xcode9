//
//  PlanTaskTableView.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 3/7/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PlanTaskTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    var parent: AdjustPlanViewController?
    var parent2: NowViewController?
    var arr = groups
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = arr[indexPath.row] as! TaskSetUp
        var c: UITableViewCell
        if task.duration == 0 && task.due == nil && task.points == 0{
            c = tableView.dequeueReusableCell(withIdentifier: "SimpleTaskCell",
                                              for: indexPath) as! TaskCell
        } else {
            c = tableView.dequeueReusableCell(withIdentifier: "TaskCell",
                                              for: indexPath) as! TaskCell
        }
        let cell = c as! TaskCell
        if cur != nil && (cur as! Group).name != "All" && (cur as! Group).name != "Today" && (cur as! Group).name != "This Week" && (cur as! Group).name != "Overdue"{
            cell.backgroundColor = color(color: task.color!)
            cell.name.text = task.name!
        } else {
            var n = task as Group
            if task.group != nil{
                n = task.group!;
                while n.group != nil {
                    n = n.group!
                }
            }
            
            if n.color == nil {
                n.color = "White"
            }
            cell.backgroundColor = color(color: ((n).color!))
            if task.group != nil {
                var g = task.group!
                while g.group != nil {
                    g = g.group!
                }
                cell.name.text = task.name! + " (" + g.name! + ")"
            } else {
                cell.name.text = task.name!
            }
        }
        //cell.checkButtonOutlet.tag = indexPath.row
        if task.due != nil && task.time == 1 {
            /*let formatter = DateFormatter()
             formatter.dateFormat = "EEEE, MM/dd 'at' HH:mm"
             let calendar = Calendar.current
             let d = task.due
             cell.due.isHidden = false
             cell.due.text = formatter.string(from: d as! Date)
             if calendar.isDateInToday(d as! Date) {
             formatter.dateFormat = " 'at' HH:mm"
             cell.due.text = "Today" + formatter.string(from: d as! Date)
             }
             
             if calendar.isDateInTomorrow(d as! Date) {
             formatter.dateFormat = " 'at' HH:mm"
             cell.due.text = "Tomorrow" + formatter.string(from: d as! Date)
             }*/
            cell.due.isHidden = false
            let d = task.due! as Date
            cell.due.text = formatDate(date: d) + " at " + formatTime(date: d)
            
        }else if task.due != nil {
            /*let formatter = DateFormatter()
             formatter.dateFormat = "EEEE, MM/dd"
             let d = task.due
             let calendar = Calendar.current
             cell.due.isHidden = false
             cell.due.text = formatter.string(from: d as! Date)
             if calendar.isDateInToday(d as! Date) {
             cell.due.text = "Today"
             }
             
             if calendar.isDateInTomorrow(d as! Date) {
             cell.due.text = "Tomorrow"
             }*/
            cell.due.isHidden = false
            let d = task.due
            cell.due.text = formatDate(date: d! as Date)
        }
        if task.priority != nil {
            cell.priority.isHidden = false
            cell.priority.text = task.priority
        } else {
            cell.priority.isHidden = true
        }
        /*if task.completed == 1 {
         cell.check.isHidden = false
         }else{
         cell.check.isHidden = true
         }*/
        
        if task.duration != 0 {
            if task.due == nil {
                cell.due.isHidden = false
                cell.due.text = formatDuration(duration: Int(task.duration))
            } else {
                cell.duration.isHidden = false
                cell.duration.text = formatDuration(duration: Int(task.duration))
            }
        }else{
            cell.duration?.isHidden = true
        }
        
        if task.points != 0 {
            if task.due == nil && task.duration == 0 {
                cell.due.isHidden = false
                cell.due.text = String(task.points) + " Points"
            } else if task.due == nil || task.duration == 0 || (task.amountDoneType != nil && task.amountDoneType == "Points") {
                cell.duration.isHidden = false
                cell.duration.text = String(task.points) + " Points"
            }
        } else {
            if task.duration == 0{
                cell.duration?.isHidden = true
            }
        }
        if getPercentDone(task: task) != 0 {
            cell.donePercent.isHidden = false
            cell.donePercent.text = String(getPercentDone(task: task)) + "% done"
        }else{
            cell.donePercent.isHidden = true
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - Split
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let split = UITableViewRowAction(style: .normal, title: "Split in 2") { action, index in
            let  task = self.arr[editActionsForRowAt.row] as! TaskSetUp
            if task.duration < 2 {
                print("Task duration in too small to split")
                return
            }
            
            if let managedContext = getManagedContext() {
                
                let entity = NSEntityDescription.entity(forEntityName: "SplitTask",
                                                        in: managedContext)!
                
                let newTask1 = NSManagedObject(entity: entity,
                                               insertInto: managedContext) as! SplitTask
                let newTask2 = NSManagedObject(entity: entity,
                                               insertInto: managedContext) as! SplitTask
                
                for property in task.entity.propertiesByName {
                    let any = task.value(forKey: property.key)
                    newTask1.setValue(any, forKey: property.key)
                    newTask2.setValue(any, forKey: property.key)
                }
                
                //divide duration mantaining entire minutes
                var dur1 = task.duration/2
                let dur2 = task.duration/2
                if task.duration % 2 == 1 {
                    dur1 += 1
                }
                newTask1.duration = dur1
                newTask2.duration = dur2
                
                if !(task is SplitTask) {
                    newTask1.parentTask = task
                    newTask2.parentTask = task
                }
                
                saveManagedContext(managedContext: managedContext)
                
                self.arr.remove(at: editActionsForRowAt.row)
                self.arr.append(newTask1)
                self.arr.append(newTask2)
                tableView.reloadData()
            }
        }
        split.backgroundColor = .blue
        // TODO: - split in 3
        let split3 = UITableViewRowAction(style: .normal, title: "Split in 3") { action, index in
            let  task = self.arr[editActionsForRowAt.row] as! TaskSetUp
            if task.duration < 2 {
                print("Task duration in too small to split")
                return
            }
            if task is SplitTask {
                print("Task is already splited")
                return
            }
            
            if let managedContext = getManagedContext() {
                
                let entity = NSEntityDescription.entity(forEntityName: "SplitTask",
                                                        in: managedContext)!
                
                let newTask1 = NSManagedObject(entity: entity,
                                               insertInto: managedContext) as! SplitTask
                let newTask2 = NSManagedObject(entity: entity,
                                               insertInto: managedContext) as! SplitTask
                let newTask3 = NSManagedObject(entity: entity,
                                               insertInto: managedContext) as! SplitTask
                
                for property in task.entity.propertiesByName {
                    let any = task.value(forKey: property.key)
                    newTask1.setValue(any, forKey: property.key)
                    newTask2.setValue(any, forKey: property.key)
                    newTask3.setValue(any, forKey: property.key)
                }
                
                //divide duration mantaining entire minutes
                var dur1 = task.duration/3
                var dur2 = task.duration/3
                let dur3 = task.duration/3
                if task.duration % 3 == 1 {
                    dur1 += 1
                }
                if task.duration % 3 == 1 {
                    dur1 += 1
                    dur2 += 1
                }
                newTask1.duration = dur1
                newTask2.duration = dur2
                newTask3.duration = dur3
                
                if !(task is SplitTask) {
                    newTask1.parentTask = task
                    newTask2.parentTask = task
                    newTask3.parentTask = task
                }
                
                saveManagedContext(managedContext: managedContext)

                self.arr.remove(at: editActionsForRowAt.row)
                self.arr.append(newTask1)
                self.arr.append(newTask2)
                self.arr.append(newTask3)
                tableView.reloadData()
            }
        }
        split3.backgroundColor = UIColor.orange
        
        let remove = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
            (self.arr[editActionsForRowAt.row] as! Task).plan = nil
            self.arr.remove(at: editActionsForRowAt.row)
            tableView.reloadData()
        }
        remove.backgroundColor = .red
        
        if (arr[editActionsForRowAt.row] as! Group).name == "Break" {
            return [remove]
        }
        return [remove, split3, split]
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cur = arr[indexPath.row]
        curArr.append(cur!)
        //loadCur()
        updateGroups()
        arr = groups
        parent?.editTask(index: indexPath.row)
        parent2?.editTask(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    // MARK: - Moving cells
    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: self)
        let indexPath = self.indexPathForRow(at: locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            static var initialIndexPath : IndexPath? = nil
        }
        
        switch state {
        case UIGestureRecognizerState.began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = self.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshotOfCell(cell!)
                
                var center = cell?.center
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                self.addSubview(My.cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        My.cellIsAnimating = false
                        if My.cellNeedToShow {
                            My.cellNeedToShow = false
                            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                                cell?.alpha = 1
                            })
                        } else {
                            cell?.isHidden = true
                        }
                    }
                })
            }
            
        case UIGestureRecognizerState.changed:
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                
                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                    arr.insert(arr.remove(at: Path.initialIndexPath!.row), at: indexPath!.row)
                    self.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                    for i in 0..<arr.count {
                        arr[i].setValue(i, forKeyPath: "index")
                    }
                    Path.initialIndexPath = indexPath
                }
            }
        default:
            if Path.initialIndexPath != nil {
                let cell = self.cellForRow(at: Path.initialIndexPath!) as UITableViewCell!
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell?.isHidden = false
                    cell?.alpha = 0.0
                }
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = (cell?.center)!
                    My.cellSnapshot!.transform = CGAffineTransform.identity
                    My.cellSnapshot!.alpha = 0.0
                    cell?.alpha = 1.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                })
            }
        }
    }
    
    func snapshotOfCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
}
