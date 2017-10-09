//
//  ColorPickerView.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 1/31/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit

class SortPicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    var parent: UIViewController?
    var arr = ["Due date", "A-Z", "Priority", "Duration", "Points"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return arr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return arr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        parent?.updateSort(sortBy: arr[row])
    }
}
