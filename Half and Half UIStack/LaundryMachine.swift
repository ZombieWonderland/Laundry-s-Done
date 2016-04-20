//
//  LaundryMachine.swift
//  LaundryTimer2
//
//  Created by Dan Livingston  on 3/28/16.
//  Copyright © 2016 Some Peril. All rights reserved.
//

import UIKit
import AVFoundation

class LaundryMachine
{
    private let name: String
    let startButton: UIButton
    let stopButton: UIButton
    private let timeDisplayLabel: UILabel
    
    private var startTime: NSTimeInterval = 0.0
    
    private var initialTime: NSTimeInterval = 0.0
    private var elapsedTime: NSTimeInterval = 0.0
    
    private var timer: NSTimer?
    private var alarm : AVAudioPlayer?
    
    var initialMinutes = [
        LaundryModel.Washer: LaundryModel.initalWasherMinutes,
        LaundryModel.Dryer: LaundryModel.initalDryerMinutes
    ]
    
    init(name: String, startButton: UIButton, stopButton: UIButton, timeDisplayLabel: UILabel){
        self.name = name
        self.startButton = startButton
        self.stopButton = stopButton
        self.timeDisplayLabel = timeDisplayLabel
        self.initialTime = Double(initialMinutes[name]! * LaundryModel.SecondsInAMinute)
        
        if let alarm = setupAudioPlayerWithFile("drums", type:"mp3") {
            self.alarm = alarm
        }
        
        resetTimer()
    }
    
    private struct Constants {
        static let SecondsInAMinute: Double = 60    // for readability
        static let NumberOfAlarmLoops = 20
    }
    
    func resetTimer() {
        // If timer already running, stop it
        timer?.invalidate()
        timer = nil
        
        // Make sure inital time is the same as what's saved in user preferences
        let defaults = NSUserDefaults.standardUserDefaults()
        let savedMinutes = defaults.integerForKey(self.name)
        if savedMinutes != 0 {
            let savedSeconds = savedMinutes * LaundryModel.SecondsInAMinute            
            if initialTime != Double(savedSeconds) && savedSeconds != 0 {
                initialTime = Double(savedSeconds)
            }
        }
        
        formatAndDisplayRemainingTime(initialTime)
        startButton.setTitle(LaundryModel.StartText, forState: .Normal)
        stopButton.setTitle(LaundryModel.StopText, forState: .Normal)
    }
    

    
    func startTimer()
    {   
        resetTimer()
        
        initializeAndFireTimer()
        
        // Change button text to "restart" since that is what tapping it will do now
        startButton.setTitle(LaundryModel.RestartText, forState: .Normal)
        

    }
    
    func initializeAndFireTimer() {
        startTime = NSDate.timeIntervalSinceReferenceDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2,
                                                       target: self,
                                                       selector: #selector(LaundryMachine.fire),
                                                       userInfo: nil,
                                                       repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        alarm?.stop()
        
        startButton.setTitle(LaundryModel.ResetText, forState: .Normal)
        stopButton.setTitle(LaundryModel.ResumeText, forState: .Normal)
    }
    
    func resumeTimer() {
        //reset timer with existing amoutn of time left
        stopButton.setTitle(LaundryModel.StopText, forState: .Normal)
        
        // update initial time to displayed time
        let remaining = getRemainingTime()
        initialTime = remaining!
        initializeAndFireTimer()
    }
    
    @objc func fire() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        elapsedTime = currentTime - startTime
        
        if elapsedTime >= initialTime {
            alertUser()
        } else {
            let timeToDisplay = initialTime - elapsedTime
            formatAndDisplayRemainingTime(timeToDisplay)
        }
    }
    
  
    func formatAndDisplayRemainingTime(timeInterval: NSTimeInterval)
    {
        let minutesToDisplay = Double(timeInterval) / Constants.SecondsInAMinute
        let secondsToDisplay = Double(timeInterval) %  Constants.SecondsInAMinute
        let formattedMinutes = String(format: "%01d", Int(minutesToDisplay))
        let formattedSeconds = String(format: "%02d", Int(secondsToDisplay))   // display with inital zero
        timeDisplayLabel.text = "\(formattedMinutes):\(formattedSeconds)"
    }
    
    func alertUser() {
        stopTimer()
        timeDisplayLabel.text = LaundryModel.ReadyText
        alarm?.numberOfLoops = Constants.NumberOfAlarmLoops
        alarm?.play()
    }
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?
    {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var audioPlayer:AVAudioPlayer?
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        return audioPlayer
    }
    
    func getInitialTime() -> NSTimeInterval {
        return initialTime
    }
    
    func setInitialTime(newInitialTime: NSTimeInterval) {
        initialTime = newInitialTime
    }
    
    // from a running timer
    func getRemainingTime() ->  NSTimeInterval?
    {
        if timer != nil {
            let currentTime = NSDate.timeIntervalSinceReferenceDate()
            let finishTime = initialTime + startTime
            return finishTime - currentTime
        } else if elapsedTime != 0.0 {
            // timer has run, btu is now stopped
            return initialTime - elapsedTime
        } else {
            return nil
        }
    }
    


}
