//
//  OrderByPicker.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 2/22/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit

class OrderByPicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    var parentVc: UIViewController?
    let arr = ["Priority", "Same List Together", "Same List Separated", "A-Z", "It Doesn't Matter"]
    
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
        parentVc?.updateOrderBy(row: row)
    }
}

