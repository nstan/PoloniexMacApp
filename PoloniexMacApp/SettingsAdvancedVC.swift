//
//  SettingsAdvancedVC.swift
//  PoloniexMacApp
//
//  Created by Nikola Stan on 8/18/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import Foundation
import Cocoa


class SettingsAdvancedVC: NSViewController {
    
    
    @IBAction func OKButtonPressed(_ sender: NSButton) {
        let originalVC = self.presenting as! HomeScreenVC
        originalVC.settingsButton.isEnabled = true
        dismissViewController(self.parent!)
        originalVC.updateView ()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
}
