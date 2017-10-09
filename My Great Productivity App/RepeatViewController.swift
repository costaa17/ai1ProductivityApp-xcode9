//
//  RepeatViewController.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 2/6/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit


class RepeatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var back: UIViewController?
    var lastSelectedIndexPath = NSIndexPath(item: -1, section: 0)
    var selected: [IndexPath] = []
    
    let days = [
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Month"]
    
    let monthIndex = IndexPath(item: 7, section: 0)
    var selectedDay:String?
    var selectedDayIndex:Int?
    var cell:UITableViewCell?
    
    
    override func viewDidLoad() {
        //navigationController?.navigationBar.topItem?.title = "Back"
        tableView.delegate = self
        tableView.dataSource = self
        showCompleted = false
        tableView.reloadData()
    }
    
    
    @IBAction func doneButton(_ sender: Any) {
        var n = 0
        for index in selected {
            if index.item != -1{
                n += Int(pow(Double(2), Double(index.item)))
            }
        }
        back?.updateRepeat(num: n)
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell", for: indexPath as IndexPath) as UITableViewCell
        
        if !selected.contains(indexPath) {
            cell.accessoryType = .none
        }else{
            cell.accessoryType = .checkmark
        }
        cell.textLabel?.text = days[indexPath.row]
        selectedDay = days[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if selected.contains(indexPath) {
                if indexPath == monthIndex {
                    selected.removeAll()
                    tableView.reloadData()
                } else {
                    cell.accessoryType = .none
                    selected.remove(at: selected.index(of: indexPath)!)
                }
            } else {
                if indexPath == monthIndex {
                    selected.removeAll()
                    tableView.reloadData()
                    selected.append(indexPath)
                } else {
                    if selected.contains(monthIndex) {
                        selected.remove(at: selected.index(of: monthIndex)!)
                        tableView.reloadData()
                    }
                    selected.append(indexPath)
                    cell.accessoryType = .checkmark
                }
            }
        }
        
    }
}
