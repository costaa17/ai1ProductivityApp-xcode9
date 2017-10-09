//
//  PointsPickerView.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 2/3/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GroupsPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var parent: UIViewController?
    var arr: [NSManagedObject] = []
    func setupArr() {
        
        if let managedContext = getManagedContext() {
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "List")
            if let name = (cur as! Group).name {
                let predicate = NSPredicate(format: "name != %@ && name != %@ && name != %@ && name != %@", argumentArray: [name, "Today", "This Week", "Overdue"])
                fetchRequest.predicate = predicate
            }
            
            do {
                arr = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Task")
            let predicate2 = NSPredicate(format: "completed != %@", argumentArray: [1])
            fetchRequest2.predicate = predicate2
            
            do {
                let arr2 = try managedContext.fetch(fetchRequest2)
                arr.append(contentsOf: arr2)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func setupArrIncludingCur() {
        
        if let managedContext = getManagedContext() {
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Group")
            //let predicate = NSPredicate(format: "name != %@ && name != %@", argumentArray: [ "Today", "This Week"])
            //fetchRequest.predicate = predicate
            do {
                arr = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Task")
            //let predicate2 = NSPredicate(format: "completed != %@", argumentArray: [1])
            //fetchRequest2.predicate = predicate2
            do {
                let arr2 = try managedContext.fetch(fetchRequest2)
                arr.append(contentsOf: arr2)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (arr[row] as! Group).name == nil{
            return ""
        }
        
        return (arr[row] as! Group).name!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        parent?.updateGroup(group: arr[row])
    }
}
