//
//  nowViewController.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 3/24/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MediaPlayer

class NowViewController: UITableViewController {
    
    //MARK: - Task variables
    var currentTask: TaskSetUp!
    
    @IBOutlet weak var taskName: UILabel!
    
    @IBOutlet weak var taskDuration: UILabel!
    
    @IBOutlet weak var taskPoints: UILabel!
    
    
    //MARK: - Timer variables
    var timer = Timer()
    
    var counter = 0
    
    var timerSet = false
    
    var playing = false
    
    //MARK: - Music variables
    @IBOutlet weak var musicName: UILabel!
    
    
    //MARK: - Plan variables
    @IBOutlet weak var planStartTime: UILabel!
    
    @IBOutlet weak var planEndTime: UILabel!
    
    @IBOutlet weak var upNextTableView: PlanTaskTableView!
    
    @IBOutlet weak var addBreakLabel: UIBarButtonItem!
    
    @IBOutlet weak var breakDurationStepper: UIStepper!
    
    var plan: Plan!
    
    var firstTask = true
    
    var addTask: Task?
    
    
    //MARK: - Setup
    override func viewDidLoad() {
        fetchPlan()
        fetchPlanTasks()
        setupMusicPlayer()
        setupPlanInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //fetch for the current plan
        print(currentTask)
        if currentTask == nil || counter/60 >= Int(currentTask.duration) {
            nextTask()
        } else {
            startButton(0)
            timerSet = true
        }
        
        groups = upNextTableView.arr
        
        //add new task to the plan
        if addTask != nil {
            addTask?.plan = plan
            upNextTableView.arr.append(addTask!)
            groups = upNextTableView.arr
            plan?.planIten = NSSet(array: upNextTableView.arr)
            let calendar = NSCalendar.current
            let endTime = calendar.date(byAdding: .minute, value: Int(addTask!.duration), to: plan!.endTime! as Date)
            plan?.endTime = endTime as NSDate?
        }
        planEndTime.text = "End time: " + formatTime(date: plan!.endTime! as Date)
        upNextTableView.reloadData()
    }
    
    func setupPlanInfo() {
        planStartTime.text = "Start time: " + formatTime(date: plan.startTime! as Date)
        planEndTime.text = "End time: " + formatTime(date: plan.endTime! as Date)
        let arr = plan.planIten?.allObjects as! [NSManagedObject]
        groups = arr
        let longpress = UILongPressGestureRecognizer(target: upNextTableView, action: Selector(("longPressGestureRecognized:")))
        upNextTableView.addGestureRecognizer(longpress)
        upNextTableView.arr = arr
        upNextTableView.parent2 = self
        upNextTableView.delegate = upNextTableView
        upNextTableView.dataSource = upNextTableView
        upNextTableView.reloadData()
        breakDurationStepper.value = 10
    }
    
    func setupMusicPlayer() {
        let player = MPMusicPlayerController.systemMusicPlayer()
        
        let currentSongTitle = player.nowPlayingItem?.title
        
        musicName.text = currentSongTitle
    }
    
    func fetchPlan() {
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
        components.day! += 1
        let dateTo = calendar.date(from: components)! // eg. 2016-10-11 00:00:00
        // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time
        
        if let managedContext = getManagedContext() {
            
            
            // Set predicate as date being today's date
            let predicate = NSPredicate(format: "(%@ <= startTime) AND (startTime < %@)", argumentArray: [dateFrom, dateTo])
            
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Plan")
            
            do {
                fetchRequest.predicate = predicate
                
                //crashes if no plan on this date
                try plan = managedContext.fetch(fetchRequest)[0] as! Plan
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
    }
    
    func fetchPlanTasks() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PlanIten")
        
        let predicate = NSPredicate(format: "plan == %@", argumentArray: [plan])
        
        let sortDescriptor =  NSSortDescriptor.init(key: "planIndex", ascending: true)
        
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            
            upNextTableView.arr = try managedContext.fetch(fetchRequest)
            
        } catch let error as NSError {
            
            print("Could not fetch. \(error), \(error.userInfo)")
            
        }
    }
    
    func nextTask() {
        if upNextTableView.arr.count == 0{
            print("plan finished")
            timer.invalidate()
            return
        }
        counter = 0
        if(!firstTask) {
            startButton(0)
            timerSet = true
        } else {
            firstTask = false
        }
        currentTask = upNextTableView.arr[0] as! TaskSetUp
        taskName.text = currentTask.name!
        taskPoints.text = String(currentTask.points) + " points"
        taskDuration.text = "0/" + formatDuration(duration: Int(currentTask.duration))
    }
    
    //MARK: - Task functions
    @IBAction func minus5Button(_ sender: Any) {
        updateTaskDuration(minutes: -5)
    }
    
    @IBAction func minus1Button(_ sender: Any) {
        updateTaskDuration(minutes: -1)
    }
    
    @IBAction func plus1Button(_ sender: Any) {
        updateTaskDuration(minutes: 1)
    }
    
    @IBAction func plus5Button(_ sender: Any) {
        updateTaskDuration(minutes: 5)
    }
    
    func updateTaskDuration(minutes: Int) {
        //current task duration decrease/increase min
        currentTask.duration += Int64(minutes)
        
        if currentTask.duration <= 0 {
            currentTask.duration = 0
        }
        
        if let managedContext = getManagedContext() {
            saveManagedContext(managedContext: managedContext)
        }
        
    }
    
    func completeTask() {
        // Mark task as done and remove it from the plan
        currentTask.completed = 1
        upNextTableView.arr.remove(at: 0)
    }
    
    @IBAction func skipTaskButton(_ sender: Any) {
        upNextTableView.arr.append(upNextTableView.arr.remove(at: 0))
        nextTask()
    }
    
    @IBAction func playTaskButton(_ sender: Any) {
        if timerSet {
            timer.invalidate()
            timerSet = false
        } else {
            startButton(0)
            timerSet = true
        }
    }
    
    @IBAction func pauseTaskButton(_ sender: Any) {
        playTaskButton(0)
    }
    
    @IBAction func doneTaskButton(_ sender: Any) {
        nextTask()
    }
    
    
    //MARK: - Timer functions
    func updateCounter() {
        setupMusicPlayer()
        counter +=  1
        if counter != 0 {
            taskDuration.text = formatDuration(duration: counter/60) + "/" + formatDuration(duration: Int(currentTask.duration))
        }
        if counter/60 >= Int(currentTask.duration) {
            timer.invalidate()
            timerSet = false
            performSegue(withIdentifier: "TaskDone", sender: self)
        }
    }
    
    //MARK: - Music functions
    @IBAction func backMusicButton(_ sender: Any) {
        let player = MPMusicPlayerController.systemMusicPlayer()
        player.skipToPreviousItem()
    }
    
    @IBAction func playMusicButton(_ sender: Any) {
        pauseMusicButton(0)
    }
    
    @IBAction func pauseMusicButton(_ sender: Any) {
        let player = MPMusicPlayerController.systemMusicPlayer()
        if player.playbackState == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    @IBAction func nextMusicButton(_ sender: Any) {
        let player = MPMusicPlayerController.systemMusicPlayer()
        player.skipToNextItem()
    }
    
    
    //MARK: - Plan functions
    @IBAction func breakDurationStepperChanged(_ sender: UIStepper) {
        addBreakLabel.title = "Add " + formatDuration(duration: Int(sender.value)) + " break"
    }
    
    @IBAction func addExistingTaskButton(_ sender: Any) {
        performSegue(withIdentifier: "choseTask", sender: self)
    }
    
    @IBAction func addNewTaskButton(_ sender: Any) {
        
    }
    
    @IBAction func addBreakButton(_ sender: Any) {
        
        //Save plan order
        for i in 0..<upNextTableView.arr.count {
            let task = upNextTableView.arr[i] as! PlanIten
            task.planIndex = Int64(i)
        }
        
        //All copied and pasted from AdjustPlanViewController
        if let managedContext = getManagedContext() {
            
            let entity = NSEntityDescription.entity(forEntityName: "Break",
                                                    in: managedContext)!
            
            let breakEntity = NSManagedObject(entity: entity,
                                              insertInto: managedContext) as! Break
            breakEntity.duration = Int64(breakDurationStepper.value)
            
            breakEntity.name = "Break"
            
            upNextTableView.arr.append(breakEntity)
            groups = upNextTableView.arr
            
            let calendar = NSCalendar.current
            let endTime = calendar.date(byAdding: .minute, value: Int(breakDurationStepper.value), to: plan!.endTime! as Date)
            plan?.endTime = endTime as NSDate?
            planEndTime.text = "End time: " + formatTime(date: plan!.endTime! as Date)
            upNextTableView.reloadData()
            
            saveManagedContext(managedContext: managedContext)
        }
    }
    
    override func editTask(index: Int) {
        performSegue(withIdentifier: "EditPlanTask", sender: self)
    }
    
    //MARK: - View control
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func startButton(_ sender: Any) {
        if !timerSet {
            timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(NowViewController.updateCounter), userInfo: nil, repeats: true)
            timerSet = true
            playing = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let taskDoneVC = segue.destination as?  TaskDoneViewController{
            taskDoneVC.parentVC = sender as? NowViewController
        }
        if let adjustPlanViewController = segue.destination as? ChoseTaskViewController {
            adjustPlanViewController.parentVC2 = sender as? NowViewController
            adjustPlanViewController.thisPlan = plan
        }
    }
}
