//
//  ExistingPlansTableView.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 3/19/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ExistingPlansTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var plans: [NSManagedObject]?
    var row  = 0;
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        // get all plans
        
        if let managedContext = getManagedContext() {
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Plan")
            
            do {
                
                plans = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                
                print("Could not fetch. \(error), \(error.userInfo)")
                
            }
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plans!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let plan = plans![indexPath.row] as! Plan
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = formatDate(date: plan.startTime! as Date)
        cell.showsReorderControl = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get tasks on selected plan
        var tasks: [NSManagedObject] = []
        
        if let managedContext = getManagedContext() {
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PlanIten")
            
            let predicate = NSPredicate(format: "plan == %@", argumentArray: [plans![indexPath.item]])
            
            let sortDescriptor =  NSSortDescriptor.init(key: "planIndex", ascending: true)
            
            fetchRequest.predicate = predicate
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            row = indexPath.item;
            
            do {
                
                tasks = try managedContext.fetch(fetchRequest)
                
            } catch let error as NSError {
                
                print("Could not fetch. \(error), \(error.userInfo)")
                
            }
        }
        //edit plan
        performSegue(withIdentifier: "AdjustExistingPlan", sender: tasks)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            if let managedContext = getManagedContext() {
                
                managedContext.delete(plans![indexPath.row])
                saveManagedContext(managedContext: managedContext)
                plans!.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let adjustPlanViewController = segue.destination as? AdjustPlanViewController {
            adjustPlanViewController.planTasks = sender as! [Task]!
            adjustPlanViewController.curPlan = plans![row] as? Plan
        }
    }
}
