//
//  Colors.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 1/28/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit

let blue = UIColor(red: 164/255, green: 241/255, blue: 249/255, alpha: 1)
let green = UIColor(red: 171/255, green: 247/255, blue: 131/255, alpha: 1)
let purple = UIColor(red: 210/255, green: 164/255, blue: 249/255, alpha: 1)
let orange = UIColor(red: 247/255, green: 203/255, blue: 133/255, alpha: 1)
let darkBlue = UIColor(red: 147/255, green: 185/255, blue: 242/255, alpha: 1)
let pink = UIColor(red: 232/255, green: 147/255, blue: 242/255, alpha: 1)
let darkGreen = UIColor(red: 158/255, green: 209/255, blue: 131/255, alpha: 1)
let yellow = UIColor(red: 249/255, green: 243/255, blue: 122/255, alpha: 1)
let gray = UIColor(red: 114/255, green: 114/255, blue: 105/255, alpha: 1)
let red = UIColor(red: 237/255, green: 117/255, blue: 104/255, alpha: 1)

func color(color: String) -> UIColor{
    switch color {
    case "White":
        return UIColor.white
    case "Blue":
        return blue
    case "Green":
        return green
    case "Purple":
        return purple
    case "Orange":
        return orange
    case "Dark Blue":
        return darkBlue
    case "Pink":
        return pink
    case "Dark Green":
        return darkGreen
    case "Yellow":
        return yellow
    case "Gray":
        return gray
    default:
        return red
    }
    
}
