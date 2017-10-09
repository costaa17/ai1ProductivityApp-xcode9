//
//  TaskCell.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 1/30/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit

class TaskCell: UITableViewCell{
    
    //not checked
    
    @IBOutlet weak var name: UILabel!

    
    @IBOutlet weak var checkButtonOutlet: UIButton!
    
    //hidden
    @IBOutlet weak var due: UILabel!
    
    //hidden
    @IBOutlet weak var check: UIImageView!
    
    //hidden
    @IBOutlet weak var priority: UILabel!
    
    
    @IBOutlet weak var duration: UILabel!
    
    @IBOutlet weak var donePercent: UILabel!
    
    @IBAction func checkButton(_ sender: Any) {
        let im = UIImage(named: "checked")
        checkButtonOutlet.setImage(im, for: .normal)
    }
    
    
    
    override func awakeFromNib() {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
}
