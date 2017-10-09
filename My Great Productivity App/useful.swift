//
//  useful.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 2/3/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

var showCompleted = false


func formatDate(date: Date) -> String {
    /*let formatter = DateFormatter()
     formatter.dateStyle = .short
     return formatter.string(from: date)*/
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MM/dd"
    let d = date
    let calendar = Calendar.current
    if calendar.isDateInToday(d) {
        return "Today"
    }
    
    if calendar.isDateInTomorrow(d) {
        return "Tomorrow"
    }
    
    return formatter.string(from: d)
}

func formatRepeat(num: Int) -> String{
    if num == 0{
        return ""
    }
    let str = String(num, radix: 2)
    let chars = Array(str.characters)
    var arr: [[String]] = []
    var result =  "Every "
    if num == 127 {
        return "Everyday"
    }
    if num == 62 {
        return "Every weekday"
    }
    //create the intervals
    let days = ["Sunday",
                "Monday",
                "Tuesday",
                "Wednesday",
                "Thursday",
                "Friday",
                "Saturday"]
    var range = false
    for i in 0...6 {
        if str.characters.count > i && chars[chars.count - 1 - i] == "1" {
            if range {
                arr[arr.count - 1].append(days[i])
            }else{
                let a = [days[i]]
                arr.append(a)
                range = true;
            }
        } else {
            range = false
        }
    }
    
    if str.characters.count > 7 && chars[chars.count - 8] == "1" {
        return "Every Month"
    }
    
    //merge first and last intervals
    if str.characters.count > 6 && chars[chars.count - 7] == "1"  && chars[chars.count - 1] == "1" {
        var a = arr[arr.count - 1]
        for s in arr[0] {
            a.append(s)
        }
        arr[0] = a
        arr.removeLast()
    }
    for range in arr {
        if range.count == 1 {
            result += range[0] + ", "
        }else if range.count == 2 {
            result += range[0] + ", " + range[1] + ", "
        }else{
            result += range[0] + " to " + range[range.count - 1] + ", "
        }
    }
    result = result.substring(to: result.index(before: result.endIndex))
    result = result.substring(to: result.index(before: result.endIndex))
    return result
}

func getNextRepeatDate(num: Int, date: Date) -> Date?{
    var weekdaySet: IndexSet = []
    if num == 0{
        return nil
    }
    let str = String(num, radix: 2)
    let chars = Array(str.characters)
    
    for i in 0...6 {
        if str.characters.count > i && chars[chars.count - 1 - i] == "1" {
            weekdaySet.insert(i + 1)
        }
    }
    
    if str.characters.count > 7 && chars[chars.count - 8] == "1" {
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: date) // eg. 2016-10-10 00:00:00
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
        components.month! += 1
        let dateTo = calendar.date(from: components)! // eg. 2016-10-11 00:00:00
        
        return dateTo
    }
    
    // Get the current calendar and the weekday from today
    let calendar = Calendar.current
    var weekday =  calendar.component(.weekday, from: date)
    
    // Calculate the next index
    if let nextWeekday = weekdaySet.integerGreaterThan(weekday) {
        weekday = nextWeekday
    } else {
        weekday = weekdaySet.first!
    }
    
    // Get the next day matching this weekday
    let components = DateComponents(weekday: weekday)
    return calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)
}
func formatTime(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

func getDuration(date: Date) -> Int {
    let formatter = DateFormatter()
    var duration: Int?
    formatter.dateFormat = "HH:mm"
    let index = formatter.string(from: date).index(formatter.string(from: date).startIndex, offsetBy: 2)
    duration = Int(formatter.string(from: date).substring(to: index))
    if duration != nil {
        duration = duration! * 60
    }
    let index2 = formatter.string(from: date).index(formatter.string(from: date).startIndex, offsetBy: 3)
    if duration != nil {
        let i = Int(formatter.string(from: date).substring(from: index2))!
        duration = duration! + i
    } else {
        duration = Int(formatter.string(from: date).substring(from: index2))!
    }
    return duration!
}

func formatDuration(duration: Date) -> String {
    let min = getDuration(date: duration) % 60
    let h = getDuration(date: duration) / 60
    var s = ""
    if h > 0 {
        s += String(h)
        if h == 1 {
            s += " hour"
        } else {
            s += " hours"
        }
        if min != 0 {
            s += " and "
        }
    }
    if min != 0 {
        s += String(min)
        if min == 1 {
            s += " minute"
        } else {
            s += " minutes"
        }
    }
    return s
}
func formatDuration(duration: Int) -> String {
    let min = duration % 60
    let h = duration / 60
    var s = ""
    if h > 0 {
        s += String(h)
        if h == 1 {
            s += " hour"
        } else {
            s += " hours"
        }
        if min != 0 {
            s += " and "
        }
    }
    if min != 0 {
        s += String(min)
        if min == 1 {
            s += " minute"
        } else {
            s += " minutes"
        }
    }
    return s
}

func combineDateWithTime(date: Date, time: Date) -> Date? {
    let calendar = NSCalendar.current
    
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
    
    var mergedComponments = DateComponents()
    mergedComponments.year = dateComponents.year!
    mergedComponments.month = dateComponents.month!
    mergedComponments.day = dateComponents.day!
    mergedComponments.hour = timeComponents.hour!
    mergedComponments.minute = timeComponents.minute!
    mergedComponments.second = timeComponents.second!
    
    return calendar.date(from: mergedComponments)
}

func updateGroups() {
    helper(showComp: showCompleted, sortBy: nil, pred: nil)
}

func updateGroups(showComp: Bool) {
    helper(showComp: showComp, sortBy: nil, pred: nil)
}

func sortGroupsBy(sortBy: NSSortDescriptor) {
    helper(showComp: showCompleted, sortBy: sortBy, pred: nil)
}

func sortGroupsByWithPred(sortBy: NSSortDescriptor, pred: NSPredicate) {
    helper(showComp: showCompleted, sortBy: sortBy, pred: pred)
}

func updateGroupsWithPred(pred: NSPredicate) {
    helper(showComp: showCompleted, sortBy: nil, pred: pred)
}

func helper(showComp: Bool, sortBy: NSSortDescriptor?, pred: NSPredicate?) {
    for i in 0..<groups.count {
        (groups[i] as! Group).index = Int64(i)
    }
    if cur is Group {
        let g = cur as! Group
        
        if let managedContext = getManagedContext() {
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
            let sortDescriptor0 =  NSSortDescriptor.init(key: "completed", ascending: true)
            let sortDescriptor =  NSSortDescriptor.init(key: "index", ascending: true)
            if sortBy == nil {
                fetchRequest.sortDescriptors = [sortDescriptor0, sortDescriptor]
            }else{
                fetchRequest.sortDescriptors = [sortDescriptor0, sortBy!]
            }
            var predicate = NSPredicate(format: "group = %@", argumentArray: [g])
            if (cur as! Group).name != "All" && (cur as! Group).name != "Today" && (cur as! Group).name != "This Week"{
                if !showComp {
                    predicate = NSPredicate(format: "group = %@ && completed = %@", argumentArray: [g, 0])
                }
                fetchRequest.predicate = predicate
            }
            
            if (cur as! Group).name == "Today" || (cur as! Group).name == "This Week"{
                // Get the current calendar with local time zone
                var calendar = Calendar.current
                calendar.timeZone = NSTimeZone.local
                
                // Get today's beginning & end
                let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
                var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
                if (cur as! Group).name == "Today" {
                    components.day! += 1
                } else {
                    components.day! += 7
                }
                let dateTo = calendar.date(from: components)! // eg. 2016-10-11 00:00:00
                // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time
                
                // Set predicate as date being today's date
                predicate = NSPredicate(format: "(%@ <= due) AND (due < %@)", argumentArray: [dateFrom, dateTo])
                if !showComp{
                    predicate = NSPredicate(format: "(%@ <= due) AND (due < %@) && completed = %@", argumentArray: [dateFrom, dateTo, 0])
                }
                fetchRequest.predicate = predicate
                //predicate = NSPredicate(format: "completed = %@", argumentArray: [0])
                if sortBy == nil {
                    fetchRequest.sortDescriptors = [sortDescriptor0, NSSortDescriptor.init(key: "due", ascending: true)]
                }
            }
            if (cur as! Group).name == "Overdue" {
                // Get the current calendar with local time zone
                var calendar = Calendar.current
                calendar.timeZone = NSTimeZone.local
                
                // Get today's beginning
                let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
                let dateFrom2 = Date()
                
                predicate = NSPredicate(format: "(due < %@ AND time == 0) OR (due < %@ AND time == 1)", argumentArray: [dateFrom, dateFrom2])
                if !showComp{
                    predicate = NSPredicate(format: "((due < %@ AND time == 0) OR (due < %@ AND time == 1)) && completed = %@", argumentArray: [dateFrom, dateFrom2, 0])
                }
                fetchRequest.predicate = predicate
                //predicate = NSPredicate(format: "completed = %@", argumentArray: [0])
                if sortBy == nil {
                    fetchRequest.sortDescriptors = [sortDescriptor0, NSSortDescriptor.init(key: "due", ascending: true)]
                }
            }
            if (cur as! Group).name == "All" {
                // Get the current calendar with local time zone
                var calendar = Calendar.current
                calendar.timeZone = NSTimeZone.local
                
                predicate = NSPredicate(format: "name != %@", argumentArray: ["Break"])
                if !showComp{
                    predicate = NSPredicate(format: "name != %@ && completed = %@", argumentArray: ["Break", 0])
                }
                fetchRequest.predicate = predicate
                //predicate = NSPredicate(format: "completed = %@", argumentArray: [0])
                if sortBy == nil {
                    fetchRequest.sortDescriptors = [sortDescriptor0, NSSortDescriptor.init(key: "due", ascending: true)]
                }
            }
            
            if pred != nil {
                let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [fetchRequest.predicate!, pred!])
                fetchRequest.predicate = predicateCompound
            }
            
            fetchGroups(fetchRequest: fetchRequest)
        }
    }
}

func getPercentageOfCompletedSubtasks(task: TaskSetUp) -> Int{
    
    if let managedContext = getManagedContext() {
        
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        let predicate = NSPredicate(format: "group = %@", argumentArray: [task])
        fetchRequest.predicate = predicate
        var subts: [NSManagedObject] = []
        do {
            subts = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        if subts.count == 0 {
            return 0
        }
        var percent: Int = 0
        for s in subts {
            percent += (getPercentDone(task: s as! Task))
        }
        percent /= subts.count
        return percent
    }
    return 0
}

func getPercentageOfCompletedSubtasksPointsOrDur(task: TaskSetUp, pointsOrDur: Bool) -> Int{ //true = points, false = duration
    
    if let managedContext = getManagedContext() {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        let predicate = NSPredicate(format: "group = %@", argumentArray: [task])
        fetchRequest.predicate = predicate
        var subts: [NSManagedObject] = []
        do {
            subts = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        var percent: Int = 0
        var totalPoints = 0
        if pointsOrDur {
            for s in subts {
                percent += (getPercentDone(task: s as! Task)) * Int((s as! Task).points)
                totalPoints += Int((s as! Task).points)
            }
        } else {
            for s in subts {
                percent += (getPercentDone(task: s as! Task)) * Int((s as! Task).duration)
                totalPoints += Int((s as! Task).duration)
            }
        }
        if totalPoints == 0 {
            return 0
        }
        percent /= totalPoints
        return percent
    }
    
    return 0
}

func getPercentDone(task: TaskSetUp) -> Int{
    var percent = 0
    if task.amountDoneType != nil && task.amountDoneType == "Duration" && task.duration != 0 {
        
        percent = Int(floor((Double(task.amountDone) / Double(task.duration))*100))
        
    } else if task.amountDoneType != nil && task.amountDoneType == "Points" && task.amountDone != 0 {
        
        percent = Int(floor((Double(task.amountDone) / Double(task.points))*100))
        
    } else if task.amountDoneType != nil && task.amountDoneType == "N of Subtasks" {
        
        percent = getPercentageOfCompletedSubtasks(task: task)
        
    } else if task.amountDoneType != nil && task.amountDoneType == "Subt Duration" {
        
        percent = getPercentageOfCompletedSubtasksPointsOrDur(task: task, pointsOrDur: false)
        
    } else if task.amountDoneType != nil && task.amountDoneType == "Subt Points" {
        
        percent = getPercentageOfCompletedSubtasksPointsOrDur(task: task, pointsOrDur: true)
        
    }
    
    if task.completed == 1 {
        percent = 100
    }
    return percent
}

func backButtonUpdateCur() {
    if curArr.count > 0 {
        curArr.removeLast()
    }
    if curArr.count == 0 {
        cur = nil
    } else {
        cur = curArr.last
    }
}

func getManagedContext() -> NSManagedObjectContext?{
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        return appDelegate.persistentContainer.viewContext
    }
    print("error")
    return nil
}

func saveManagedContext(managedContext: NSManagedObjectContext) -> Bool {
    do {
        try managedContext.save()
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
        return false
    }
    return true
}

func fetchGroups(fetchRequest: NSFetchRequest<NSManagedObject>) {
    
    if let managedContext = getManagedContext() {
        do {
            groups = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
