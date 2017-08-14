//
//  HomeScreenVC.swift
//  PoloniexMacApp
//
//  Created by Nikola Stan on 8/11/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import Foundation
import Cocoa



class HomeScreenVC: NSViewController {
    var keys: APIKeys?
    
    var vc: NSViewController = NSViewController()
    
    @IBOutlet weak var settingsButton: NSButton!
    
    @IBAction func settingsButtonPressed(_ sender: NSButton) {
        showAuthenticationVCasSheet ()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initiate the objects in the view
        settingsButton.isEnabled = true
        
        
    }
    
    override func viewDidAppear() {
        // initial check for existence of API keys
        guard let keys = KeyLoader.loadKeys(keychainKeyPublicKey, keychainKeySecretKey) else {
            print ("no keys")
            self.keys = APIKeys(key: "", secret: "")
            showAuthenticationVCasSheet()
            return
        }
        self.keys = keys
        print("keys exist: " + (keys.key))
        print("Home Screen view appeared")

    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    func showAuthenticationVCasSheet () {
        self.settingsButton.isEnabled=false
        let destVC = storyBoard.instantiateController(withIdentifier: "authenticationViewController") as! AuthenticationVC
        destVC.keys = KeyLoader.loadKeys(keychainKeyPublicKey, keychainKeySecretKey) ?? APIKeys(key: "", secret: "")

        self.presentViewControllerAsSheet(destVC)
    }
    
}
