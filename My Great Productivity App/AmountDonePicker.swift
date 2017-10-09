//
//  PriorityPickerView.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 2/3/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class AmountDonePicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var parent: UIViewController?
    var arr: [String] = [] //"Duration", "Points", "N of Subtasks", "Subt Points", "Subt Duration"
    var pAndDNotSelected = false
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if (cur as! Task).duration == 0 && (cur as! Task).points == 0 || pAndDNotSelected {
            return 1
        }
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        updateArr()
        if component == 0 {
            return arr.count
        } else {
            if arr[self.selectedRow(inComponent: 0)] == "Duration" {
                return Int((cur as! Task).duration)
            }
            if arr[self.selectedRow(inComponent: 0)] == "Points" {
                return Int((cur as! Task).points)
            }
            return 0;
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return arr[row]
        } else {
            return String(row + 1)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let s = arr[self.selectedRow(inComponent: 0)]
        if s == "Duration" || s == "Points" {
            pAndDNotSelected = false
        } else {
            pAndDNotSelected = true
        }
        if self.numberOfComponents == 1 {
            parent?.updateAmountDone(type: s, amount: 0)
        } else {
            parent?.updateAmountDone(type: s, amount: self.selectedRow(inComponent: 1) + 1)
        }
    }
    
    func updateArr() {
        arr = []
        if (cur as! Task).duration != 0 {
            arr.append("Duration")
        }
        if (cur as! Task).points != 0 {
            arr.append("Points")
        }
        arr.append("N of Subtasks")
        arr.append("Subt Points")
        arr.append("Subt Duration")
    }
}
