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

class PointsPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var parent: UIViewController?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2000
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        parent?.updatePoints(points: row + 1)
    }
}
