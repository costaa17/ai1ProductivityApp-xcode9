//
//  CreateListTableViewController.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 1/31/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CreateListTableViewController:  UITableViewController {
    
    @IBOutlet weak var colorPicker: ColorPickerView!
    
    @IBOutlet weak var colorCell: UITableViewCell!
    
    @IBOutlet weak var nametextField: UITextField!
    
    @IBAction func doneButton(_ sender: Any) {
        saveList()
    }
    @IBOutlet weak var NavBarIten: UINavigationItem!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //When done button clicked -> save
        if segue.identifier == "DoneCreatingList" {
            saveList()
        }
    }
    
    override func viewDidLoad() {
        //NavBarIten.title = "My Title"
        colorPicker.dataSource = colorPicker
        colorPicker.delegate = colorPicker
        colorPicker.reloadAllComponents()
        colorPicker.parent = self
    }
    
    //Set cell color -> called when picker has changed
    override func updateColor (row: Int) {
        colorCell.backgroundColor = color(color: colorsArray[row])
    }
    
    func saveList() {
        if nametextField.text != ""{
            
            if let managedContext = getManagedContext() {
                
                let entity = NSEntityDescription.entity(forEntityName: "List",
                                                        in: managedContext)!
                
                let list = NSManagedObject(entity: entity,
                                           insertInto: managedContext)
                
                list.setValue(nametextField.text, forKeyPath: "name")
                list.setValue(colorsArray[colorPicker.selectedRow(inComponent: 0)], forKey: "color")
                
                if saveManagedContext(managedContext: managedContext) {
                    groups.append(list)
                }
            }
        }
    }
}


