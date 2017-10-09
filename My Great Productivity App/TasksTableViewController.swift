//
//  TasksTableViewController.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 2/3/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TasksTableViewController: UITableView, UITableViewDelegate, UITableViewDataSource {
    var parent: UIViewController?
    var arr = groups
    
    @IBAction func checkButton(_ sender: Any) {
        check(sender)
    }
    
    @IBAction func checkButton2(_ sender: Any) {
        check(sender)
    }
    
    @IBAction func checkButton3(_ sender: Any) {
        check(sender)
    }
    
    @IBAction func checkButton4(_ sender: Any) {
        check(sender)
    }
    
    func check(_ sender: Any) {
        let task = arr[(sender as! UIButton).tag] as! Task
        if task.completed == 0 {
            task.completed = 1
            if task.repeatN != 0 {
                
                if let managedContext = getManagedContext() {
                    
                    let entity = NSEntityDescription.entity(forEntityName: "Task",
                                                            in: managedContext)!
                    
                    let newTask = NSManagedObject(entity: entity,
                                                  insertInto: managedContext) as! Task
                    for property in task.entity.propertiesByName {
                        let any = task.value(forKey: property.key)
                        newTask.setValue(any, forKey: property.key)
                    }
                    
                    newTask.due = combineDateWithTime(date: getNextRepeatDate(num: Int(task.repeatN), date: task.due! as Date)!, time: task.due! as Date)! as NSDate
                    newTask.completed = 0
                    
                    saveManagedContext(managedContext: managedContext)
                    
                    updateGroups()
                    arr = groups
                    self.reloadData()
                }
            }
        } else {
            task.completed = 0
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if let managedContext = getManagedContext() {
            
            saveManagedContext(managedContext: managedContext)
            
            updateGroups()
            arr = groups
            self.reloadData()
        }
    }
    func updateTaskDue() {
        
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let task = arr[indexPath.row] as! Task
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
        cell.checkButtonOutlet.tag = indexPath.row
        if task.due != nil && task.time == 1 {
        
            cell.due.isHidden = false
            let d = task.due! as Date
            cell.due.text = formatDate(date: d) + " at " + formatTime(date: d)
            
        } else if task.due != nil {
            
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
        if task.completed == 1 {
            cell.check.isHidden = false
        } else {
            cell.check.isHidden = true
        }
        
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
        } else {
            cell.donePercent.isHidden = true
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if arr[indexPath.row].value(forKeyPath: "name") as? String == "All"{
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            if let managedContext = getManagedContext() {
                
                managedContext.delete(arr[indexPath.row])
                
                saveManagedContext(managedContext: managedContext)
                
                arr.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cur = arr[indexPath.row]
        curArr.append(cur!)
        //loadCur()
        updateGroups()
        arr = groups
        parent?.editTask(index: indexPath.row)
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
