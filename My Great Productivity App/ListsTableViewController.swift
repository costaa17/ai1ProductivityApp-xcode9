//
//  ListsTableViewController.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 1/31/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ListsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var tableView: UITableView!
    
    
    //Load core data to show
    override func viewWillAppear(_ animated: Bool) {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "List")
        let sortDescriptor =  NSSortDescriptor.init(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchGroups(fetchRequest: fetchRequest)
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(ListsTableViewController.longPressGestureRecognized(_:)))
        tableView.addGestureRecognizer(longpress)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    // MARK: - Moving cells
    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
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
                let cell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshotOfCell(cell!)
                
                var center = cell?.center
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                tableView.addSubview(My.cellSnapshot!)
                
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
                    groups.insert(groups.remove(at: Path.initialIndexPath!.row), at: indexPath!.row)
                    tableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                    
                    //save new positions
                    for i in 0..<groups.count {
                        groups[i].setValue(i, forKeyPath: "index")
                    }
                    Path.initialIndexPath = indexPath
                }
            }
        default:
            if Path.initialIndexPath != nil {
                let cell = tableView.cellForRow(at: Path.initialIndexPath!) as UITableViewCell!
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
    
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let list = groups[indexPath.row] as! List
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = color(color: list.color!)
        cell.textLabel?.text = list.value(forKeyPath: "name") as? String
        cell.showsReorderControl = true
        return cell
    }
    
    //Don't allow deleting initial lists
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let list = groups[indexPath.row] as! List
        let initlists = ["All","Today","This Week","Overdue"]
        if initlists.contains(list.name!) {
            return false
        }
        return true
    }
    
    //Deleting
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            if let managedContext = getManagedContext() {
                managedContext.delete(groups[indexPath.row])
                saveManagedContext(managedContext: managedContext)
                
                groups.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cur = groups[indexPath.row]
        curArr.append(cur!)
        updateGroups()
        
        if (cur as! Group).name == "Today" {
            performSegue(withIdentifier: "showToday2", sender: self)
            
        } else if (cur as! Group).name == "Overdue" {
            performSegue(withIdentifier: "ShowOverdue", sender: self)
            
        } else {
            performSegue(withIdentifier: "ShowEditList", sender: self)
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        backButtonUpdateCur()
        dismiss(animated: true)
        
    }
    
}
