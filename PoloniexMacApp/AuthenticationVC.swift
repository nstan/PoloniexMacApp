//
//  AuthenticationVC.swift
//  PoloniexMacApp
//
//  Created by Nikola Stan on 8/11/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import Foundation
import Cocoa



class AuthenticationVC: NSViewController {
    var keys: APIKeys?
    var parentVC: HomeScreenVC?
    
    @IBOutlet weak var publicKeyTextField: NSTextField!
    @IBOutlet weak var secretKeyTextField: NSSecureTextField!
    @IBOutlet weak var saveKeysSwitch: NSButton! 
    @IBOutlet weak var continueButton: NSButton!
    
    @IBAction func saveKeysSwitchChanged(_ sender: NSButton) {
        defaults.set((sender.state != 0), forKey: "Save Keys")
    }
    
    
    @IBAction func ContinueButtonPressed(_ sender: NSButton) {
        
        // Saving the keys
        let keys = APIKeys(key: publicKeyTextField.stringValue, secret: secretKeyTextField.stringValue)
        if keys.key != "" && keys.secret != "" {
            if saveKeysSwitch.state == NSOnState {
                keychain.set(keys.key, forKey: keychainKeyPublicKey)
                keychain.set(keys.secret, forKey: keychainKeySecretKey)
            } else {
                KeyLoader.clearKeys(keychainKeyPublicKey, keychainKeySecretKey)
            }
        } else {
            dialogOK (title: "Warning", message: "Empty Key Field")
            return
        }
        self.keys = keys
        print ("Entered Key: Public ( \(keys.key) and Secret (\(keys.secret))")
        
        let originalVC = self.presenting as! HomeScreenVC
        originalVC.APIKeysButton.isEnabled = true
        originalVC.keys = keys
        dismissViewController(self)
        originalVC.updateView ()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("authentication view did load")

        

        
       
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        print("authentication view appeared")
        if self.saveKeysSwitch.state == NSOnState {print ("Switch is ON")} else {print("Switch is OFF")}
        updateView ()
        populateKeyFields ()
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    func populateKeyFields () {
        guard let k = self.keys?.key, let s = self.keys?.secret else {return}
        print ("key populated: \(k)")
        publicKeyTextField.stringValue = k
        secretKeyTextField.stringValue = s
    }


    func updateView () {
        // Tab order
        publicKeyTextField.becomeFirstResponder()
        
        // updating saveKeysSwitch to match the User defaults setting
        let x=defaults.object(forKey: "Save Keys") as! Bool? ?? true
        if x { print ("save keys user setting is ON") } else { print ("save keys user setting is OFF")}
        switch x {
        case true:
            saveKeysSwitch.state = NSOnState
        case false:
            saveKeysSwitch.state = NSOffState
            keychain.delete(keychainKeyPublicKey)
            keychain.delete(keychainKeySecretKey)
        }
        
    }
    
    func dialogOK(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    

    
    
}



