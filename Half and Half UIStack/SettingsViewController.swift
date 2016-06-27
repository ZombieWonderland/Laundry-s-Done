//
//  SettingsViewController.swift
//  LaundryTimer2
//
//  Created by Dan Livingston  on 3/29/16.
//  Copyright © 2016 Some Peril. All rights reserved.
//

import UIKit


class SettingsViewController: UIViewController, UITextFieldDelegate, KeyboardDelegate
{
    
    @IBOutlet weak var washMinutesText: UITextField!
    @IBOutlet weak var dryerMinutesText: UITextField!
    
    @IBOutlet weak var dryerScrollView: UIScrollView!
    
    var washingMinutesBeforeEditing: Int?
    var dryerMinutesBeforeEditing: Int?
    
    var keyboardCausedViewToMove = false
    
    var activeTextField = UITextField()
    
    struct Constants
    {
        static let WasherMinutesDefault = 45
        static let DryerMinutesDefault = 60
        static let Washer = "washer"
        static let Dryer = "dryer"
        static let WasherId = "washerMinutes"
        static let DryerId = "dryerMinutes"
        static let TextFieldMaxLength = 2
    }
    
    let fullMachineNames = [ Constants.Washer: "Washing machine", Constants.Dryer: "Dryer"]
    
    let defaults = UserDefaults.standard()
    
    deinit {
        NotificationCenter.default().removeObserver(self)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set up delegates so I can restrict input
        // to numbers only. This is only necessary for iPad
        // since the text fields are restricted to number pad keyboards.
        washMinutesText.delegate = self
        dryerMinutesText.delegate = self
        
        // see if user had stored Washer minutes
        if let savedWasherMinutes = defaults.string(forKey: Constants.Washer) {
            washMinutesText.text = "\(savedWasherMinutes)"
        } else {
            washMinutesText.text = "\(Constants.WasherMinutesDefault)"
        }
        
        // see if user had stored Dryer minutes
        if let savedDryerMinutes = defaults.string(forKey: Constants.Dryer) {
            dryerMinutesText.text = "\(savedDryerMinutes)"
        } else {
            dryerMinutesText.text = "\(Constants.DryerMinutesDefault)"
        }
        
        // initialize custom keyboard for iPad only, since iPhone can use the Number Pad
        if UIDevice.current().userInterfaceIdiom == .pad {
            initializeCustomKeyboard()
        }
        
        registerForKeyboardNotifications()
        setUpCancelDoneButtonsOnNumberPad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
    
    // MARK: Set up Keyboard buttons
    
    func setUpCancelDoneButtonsOnNumberPad()
    {
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        numberToolbar.barStyle = UIBarStyle.default
        
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SettingsViewController.cancelNumberPad)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SettingsViewController.doneWithNumberPad))]
        
        numberToolbar.sizeToFit()
        washMinutesText.inputAccessoryView = numberToolbar
        dryerMinutesText.inputAccessoryView = numberToolbar
    }
    
    @objc func cancelNumberPad(_ sender:UIBarButtonItem)
    {
        // restore original string value
        if let previousWashing = washingMinutesBeforeEditing {
            washMinutesText.text = "\(previousWashing)"
        }
        
        if let previousDryer = dryerMinutesBeforeEditing {
            dryerMinutesText.text = "\(previousDryer)"
        }

        doneWithNumberPad()
    }
    
    @objc func doneWithNumberPad()
    {
        washMinutesText.resignFirstResponder()
        dryerMinutesText.resignFirstResponder()
    }
    
    // MARK: Set up numbers-only Keyboard
    
    func initializeCustomKeyboard()
    {
        // initialize custom keyboard
        let keyboardView = Keyboard(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        
        // the view controller will be notified by the keyboard whenever a key is tapped
        keyboardView.delegate = self
        
        // required for backspace to work
        washMinutesText.delegate = self
        dryerMinutesText.delegate = self
        
        // replace system keyboard with custom keyboard
        washMinutesText.inputView = keyboardView
        dryerMinutesText.inputView = keyboardView
    }
    
    // MARK: React to editing text fields
    
    //
    // Editing has begun:
    //      Save state of minutes before editing starts
    //      so we can revert to it if the user taps "Cancel" in the number pad
    //
    @IBAction func washMinutesEditingBegan(_ sender: UITextField)
    {
        washingMinutesBeforeEditing = Int(washMinutesText.text!)
    }

    @IBAction func dryerMinutesEditingBegan(_ sender: UITextField)
    {
        dryerMinutesBeforeEditing = Int(dryerMinutesText.text!)
    }
    
    //
    //  Editing has ended: 
    //      check for valid ( > 0) values and
    //      Save new values of minutes to user defaults
    //
    @IBAction func washingMinutesEditingEnded(_ sender: UITextField)
    {
        minutesEditingHasFinished(sender, whichMachine: Constants.Washer)
    }

    @IBAction func dryerMinutesEditingEnded(_ sender: UITextField)
    {
        minutesEditingHasFinished(sender, whichMachine: Constants.Dryer)
    }
    
    func minutesEditingHasFinished(_ textField: UITextField, whichMachine: String)
    {
        guard let newMinutes = Int(textField.text!) where newMinutes != 0 else {
            showAlert(whichMachine)
            return
        }
        
        // Remember new values
        defaults.set(newMinutes, forKey: whichMachine)
        
        // Get rid of any preceeding zeros in the label string
        // Ex. changes "098" to 98 to "98"
        textField.text = String(Int(textField.text!)!)
        
    }
    
  
    //
    //  Show an alert if the user tries to enter in "0" or "" for minutes value
    //
    func showAlert(_ whichMachine: String) {
        let alert = UIAlertController(title: "The \(fullMachineNames[whichMachine]!) timer needs more minutes", message: "Please enter some minutes", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { (UIAlertAction) -> Void  in
            switch whichMachine {
            case Constants.Washer: self.washMinutesText.becomeFirstResponder()
            case Constants.Dryer: self.dryerMinutesText.becomeFirstResponder()
            default: break
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    
    //
    //  Make sure only numbers can appear in text fields, and
    //  limit length (see Constants.TextFieldMaxLength)
    //
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        //  Make sure only numbers can appear in text fields
        for c in string.characters
        {
            // The ~= operator (tilde and equals characters) tests to see if the range on the left contains the value on the right.
            if !("0"..."9" ~= c) {
               return false
            }
        }
        
        // Limit max length of text field
        guard let text = textField.text else { return true }
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= Constants.TextFieldMaxLength // Bool
    }
    
    //
    //  Takes the place of the 'shouldChangeCharactersInRange' delegate
    //  for the custom keyboard
    //
    @IBAction func textFieldBeingEdited(_ sender: UITextField)
    {
        if UIDevice.current().userInterfaceIdiom == .pad {
            if let text = sender.text {
                var c = text.characters
                if c.count > Constants.TextFieldMaxLength {
                    c.removeLast()
                    sender.text = String(c)
                }
            }
        }
    }

    
    //
    // MARK: required methods for keyboard delegate protocol
    //
    func keyWasTapped(_ character: String) {
        activeTextField.insertText(character)
    }
    
    func backspace() {
        activeTextField.deleteBackward()
    }
    

 
//  MARK: Moving text fields up when keyboard appears (if necessary)
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NotificationCenter.default().addObserver(self, selector: #selector(SettingsViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(SettingsViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(_ notification: Notification)
    {
        //  Calculate keyboard exact size
        let info : NSDictionary = (notification as NSNotification).userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue().size
        
        var aRect : CGRect = dryerScrollView.frame
        aRect.size.height -= keyboardSize!.height
        
        // Get text field dimensions in superview's coordinate system
        let textFieldRect = activeTextField.convert(activeTextField.bounds, to: self.view)

        if (!aRect.contains(textFieldRect.origin))
        {
            let distanceToMove = textFieldRect.origin.y - aRect.size.height
            animateViewMoving(true, moveValue: CGFloat(distanceToMove))
            keyboardCausedViewToMove = true
        }
    }
    
    func keyboardWillBeHidden(_ notification: Notification)
    {
        if keyboardCausedViewToMove {
            //Once keyboard disappears, restore original positions
            let info : NSDictionary = (notification as NSNotification).userInfo!
            let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue().size
            let textFieldRect = activeTextField.convert(activeTextField.bounds, to: self.view)
            var aRect : CGRect = dryerScrollView.frame
            aRect.size.height -= keyboardSize!.height
            let distanceToMove = textFieldRect.origin.y - aRect.size.height
            
            animateViewMoving(false, moveValue: CGFloat(distanceToMove))
            keyboardCausedViewToMove = false
        }
    }
    
    //
    //  Animate view when keyboard appears. Otherwise, dryer minutes
    //  is hidden by the keyboard.
    //
    func animateViewMoving (_ up:Bool, moveValue :CGFloat)
    {
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    


}
