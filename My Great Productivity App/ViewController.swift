//
//  ViewController.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 1/31/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import UIKit
import CoreData
import JTAppleCalendar

var groups: [NSManagedObject] = []
let colorsArray = ["White", "Blue", "Green", "Purple", "Orange", "Dark Blue", "Pink", "Dark Green", "Yellow", "Gray", "Red"]
var cur: NSManagedObject?
var curArr: [NSManagedObject] = []

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create initial lists on first open
        let launchedBefore = UserDefaults.standard.bool(forKey: "launched")
        if !launchedBefore {
            
            let toAddArr = ["All","Today","This Week","Overdue"]
            
            for list in toAddArr {
                self.saveList(name: list, color: "White")
            }
            
            UserDefaults.standard.set(true, forKey: "launched")
            
        } else {
            UserDefaults.standard.set(true, forKey: "launched")
        }
        
    }
    
    func saveList(name: String, color: String) {
        
        if let managedContext = getManagedContext() {
            
            let entity = NSEntityDescription.entity(forEntityName: "List",
                                                    in: managedContext)!
            
            let list = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
            
            list.setValue(name, forKeyPath: "name")
            list.setValue(color, forKey: "color")
            
            saveManagedContext(managedContext: managedContext)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //When done button clicked -> save
        
        backButtonUpdateCur()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "List")
        let predicate = NSPredicate(format: "name = %@", argumentArray: [segue.identifier!])
        fetchRequest.predicate = predicate
        
        fetchGroups(fetchRequest: fetchRequest)
        
        cur = groups[0]
        curArr.append(cur!)
        updateGroups()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Calendar View
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    
    
    
    
    
    
    var numberOfRows = 6
    let formatter = DateFormatter()
    var testCalendar = Calendar.current
    var generateInDates: InDateCellGeneration = .forAllMonths
    var generateOutDates: OutDateCellGeneration = .tillEndOfGrid
    var prePostVisibility: ((CellState, CellView?)->())?
    var hasStrictBoundaries = true
    let firstDayOfWeek: DaysOfWeek = .monday
    let disabledColor = UIColor.lightGray
    let enabledColor = UIColor.blue
    let dateCellSize: CGFloat? = nil
    var monthSize: MonthSize? = nil
    var prepostHiddenValue = false
    
    let red = UIColor.red
    let white = UIColor.white
    let black = UIColor.black
    let gray = UIColor.gray
    //let shade = UIColor(colorWithHexValue: 0x4E4E4E)
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = testCalendar.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        // 0 indexed array
        let year = testCalendar.component(.year, from: startDate)
        monthLabel.text = monthName + " " + String(year)
    }
    
    func handleCellConfiguration(cell: JTAppleCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        prePostVisibility?(cellState, cell as? CellView)
    }
    
    // Function to handle the text color of the calendar
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = white
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = black
            } else {
                myCustomCell.dayLabel.textColor = gray
            }
        }
    }
    
    // Function to handle the calendar selection
    func handleCellSelection(view: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell = view as? CellView else {return }
        //        switch cellState.selectedPosition() {
        //        case .full:
        //            myCustomCell.backgroundColor = .green
        //        case .left:
        //            myCustomCell.backgroundColor = .yellow
        //        case .right:
        //            myCustomCell.backgroundColor = .red
        //        case .middle:
        //            myCustomCell.backgroundColor = .blue
        //        case .none:
        //            myCustomCell.backgroundColor = nil
        //        }
        //
        if cellState.isSelected {
            myCustomCell.selectedView.layer.cornerRadius =  13
            myCustomCell.selectedView.isHidden = false
        } else {
            myCustomCell.selectedView.isHidden = true
        }
    }

// MARK : JTAppleCalendarDelegate
extension ViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = testCalendar.timeZone
        formatter.locale = testCalendar.locale
        
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2018 02 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: numberOfRows,
                                                 calendar: testCalendar,
                                                 generateInDates: generateInDates,
                                                 generateOutDates: generateOutDates,
                                                 firstDayOfWeek: firstDayOfWeek,
                                                 hasStrictBoundaries: hasStrictBoundaries)
        return parameters
    }
    
    func configureVisibleCell(myCustomCell: CellView, cellState: CellState, date: Date) {
        myCustomCell.dayLabel.text = cellState.text
        if testCalendar.isDateInToday(date) {
            myCustomCell.backgroundColor = red
        } else {
            myCustomCell.backgroundColor = white
        }
        
        handleCellConfiguration(cell: myCustomCell, cellState: cellState)
        
        
        if cellState.text == "1" {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let month = formatter.string(from: date)
            myCustomCell.monthLabel.text = "\(month) \(cellState.text)"
        } else {
            myCustomCell.monthLabel.text = ""
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // This function should have the same code as the cellForItemAt function
        let myCustomCell = cell as! CellView
        configureVisibleCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        configureVisibleCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
        return myCustomCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.setupViewsOfCalendar(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let date = range.start
        let month = testCalendar.component(.month, from: date)
        
        let header: JTAppleCollectionReusableView
        if month % 2 > 0 {
            header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "WhiteSectionHeaderView", for: indexPath)
            (header as! WhiteSectionHeaderView).title.text = formatter.string(from: date)
        } else {
            header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "PinkSectionHeaderView", for: indexPath)
            (header as! PinkSectionHeaderView).title.text = formatter.string(from: date)
        }
        return header
    }
    
    func sizeOfDecorationView(indexPath: IndexPath) -> CGRect {
        let stride = calendarView.frame.width * CGFloat(indexPath.section)
        return CGRect(x: stride + 5, y: 5, width: calendarView.frame.width - 10, height: calendarView.frame.height - 10)
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return monthSize
    }
}
}

