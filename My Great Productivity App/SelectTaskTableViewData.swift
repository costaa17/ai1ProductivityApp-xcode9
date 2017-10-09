//
//  selectTaskTableViewData.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 3/5/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit

class SelectTaskTableViewData: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    //Used to send back what task was selected
    var parentVC: ChoseTaskViewController?
    
    
    //MARK: - Table View
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parentVC?.choseTask(task: groups[indexPath.row] as! Task)
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = groups[indexPath.row] as! Task
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
        if task.completed == 1 {
            cell.check.isHidden = false
        }else{
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
        }else{
            cell.donePercent.isHidden = true
        }
        
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  1
    }
}
