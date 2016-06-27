//
//  LaundryTimerViewController.swift
//  LaundryTimer2
//
//  Created by Dan Livingston  on 3/28/16.
//  Copyright © 2016 Some Peril. All rights reserved.
//

import UIKit

protocol LaundryTimerDelegate: class {
    func getRemainingTime (_ sender: LaundryTimerViewController)
}

class LaundryTimerViewController: UIViewController {

 
    @IBOutlet weak var washerView: LaundryView!
    
    @IBOutlet weak var dryerView: LaundryView!
    
    @IBOutlet var timeLabels: [UILabel]!
    @IBOutlet var startButtons: [UIButton]!
    @IBOutlet var stopButtons: [UIButton]!
    
    var washer: LaundryMachine?
    var dryer: LaundryMachine?
    
    let appDelegate = UIApplication.shared().delegate as! AppDelegate
    
    struct Constants {
        static let ButtonWidth = CGFloat(50)
        static let ButtonHighlightBackground = UIColor(red: 0, green: 128/255, blue: 1, alpha: 0.1)
        static let ButtonNormalBorderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3).cgColor
    }
    
    // MARK: app lifecycle
    
    override func viewDidLoad()
    {
        // Make sure user is okay with getting an alert when the timer runs out
        registerLocal()
        
        washer = LaundryMachine(name: "washer", startButton: startButtons[0], stopButton: stopButtons[0], timeDisplayLabel: timeLabels[0])
        dryer = LaundryMachine(name: "dryer", startButton: startButtons[1], stopButton: stopButtons[1], timeDisplayLabel: timeLabels[1])
        
        let appDelegate = UIApplication.shared().delegate as! AppDelegate
        appDelegate.washer = washer
        appDelegate.dryer = dryer
        
        //createStartButton()
        
        configureStartButtons(startButtons)
        configureStopButtons(stopButtons)
        
    }
    
    //
    // Ensures labels display whatever changes the user made in the Settings VC
    //
    override func viewDidAppear(_ animated: Bool) {
        //createStartButton()
        setUpTimers()
    }
    
    func registerLocal() {
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
        UIApplication.shared().registerUserNotificationSettings(notificationSettings)
    }
    
    // MARK: Starting and stopping timers
    
    @IBAction func startTimer(_ sender: UIButton)
    {
        if let w = washer { startTimer(w, tappedButton: sender) }
        if let d = dryer { startTimer(d, tappedButton: sender) }
    }

    @IBAction func stopTimer(_ sender: UIButton)
    {
        if let w = washer { stopTimer(w, tappedButton: sender) }
        if let d = dryer { stopTimer(d, tappedButton: sender)  }
    }
    
    private func startTimer(_ machine: LaundryMachine, tappedButton: UIButton)
    {
        if machine.startButton == tappedButton {
            if tappedButton.currentTitle == LaundryModel.ResetText {
                machine.resetTimer()
            } else {
                machine.startTimer()
            }
        }
    }
    
    private func stopTimer(_ machine: LaundryMachine, tappedButton: UIButton)
    {
        if machine.stopButton == tappedButton {
            if tappedButton.currentTitle == LaundryModel.ResumeText {
                machine.resumeTimer()
            } else {
                machine.stopTimer()
            }
            
        }
    }
    
    // MARK: Configure buttons
    
 
    
    func configureStartButtons(_ startButtons: [UIButton]) {

        for button in startButtons {
            //button.setBackgroundImage(UIImage.imageWithColor(Constants.ButtonHighlightBackground), forState: .Highlighted)
            
            button.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
            
            
            button.layer.cornerRadius = button.bounds.size.height / 2
            button.clipsToBounds = true
            button.layer.borderWidth = 1
            button.layer.borderColor = Constants.ButtonNormalBorderColor
        }
    }
    
    func configureStopButtons(_ stopButtons: [UIButton]) {
        for button in stopButtons {
            button.layer.cornerRadius = button.bounds.size.height / 2
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray().cgColor
            button.clipsToBounds = true
            button.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
            button.layer.borderWidth = 1
            button.layer.borderColor = Constants.ButtonNormalBorderColor
//            button.setBackgroundImage(UIImage.imageWithColor(Constants.ButtonHighlightBackground), forState: .Highlighted)
        }
    }
    
    //
    //  Get initial values from saved user preferences.
    //  If no preferences, get them from Laundry Model
    //
    func setUpTimers() {
        
        let defaults = UserDefaults.standard()
        
        let savedWasherMinutes = defaults.integer(forKey: LaundryModel.Washer)
        let initialWasherMinutes = (savedWasherMinutes == 0) ? LaundryModel.initalWasherMinutes : savedWasherMinutes
        
        let savedDryerMinutes = defaults.integer(forKey: LaundryModel.Dryer)
        let initialDryerMinutes = (savedDryerMinutes == 0) ? LaundryModel.initalDryerMinutes : savedDryerMinutes
        
        if let w = washer {
            w.setInitialTime(Double(initialWasherMinutes * LaundryModel.SecondsInAMinute))
            w.formatAndDisplayRemainingTime(w.getInitialTime())
        }
        if let d = dryer {
            d.setInitialTime(Double(initialDryerMinutes * LaundryModel.SecondsInAMinute))
            d.formatAndDisplayRemainingTime(d.getInitialTime())
        }
        
    }

}


