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

class PriorityPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var parent: UIViewController?
    
    let arr = [["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"],
               ["1", "2", "3", "4", "5", "6", "7", "8", "9"]]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return arr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arr[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arr[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        parent?.updatePriority(priority: self.arr[0][self.selectedRow(inComponent: 0)] + self.arr[1][self.selectedRow(inComponent: 1)])
    }
}
