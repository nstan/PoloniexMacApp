//
//  SettingsVC.swift
//  PoloniexMacApp
//
//  Created by Nikola Stan on 8/18/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import Foundation
import Cocoa


class SettingsGeneralVC: NSViewController {
    
    var originalVC : HomeScreenVC = HomeScreenVC()
    
// Dismissing the view
    @IBAction func OKButtonPressed(_ sender: NSButton) {
        originalVC.settingsButton.isEnabled = true
        dismissViewController(self.parent!)
        originalVC.updateView ()
    }
    
    
// Currency Pair selection
    let currencyPairList = ["USDT_ETH", "BTC_ETH", "USDT_BTC"]
    var currencyPairSetting = defaults.object(forKey: "Currency Pair") as! String

    
    @IBAction func currencyPairListSelected(_ sender: NSPopUpButton) {
        guard let selectedCurrencyPair = sender.titleOfSelectedItem else {
            print("nil value in menu selection")
            return
        }
        defaults.set(selectedCurrencyPair, forKey: "Currency Pair")
        originalVC.currencyPairSetting = selectedCurrencyPair
    }
    
    @IBOutlet weak var currencyPairListSelector: NSPopUpButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalVC = self.presenting as! HomeScreenVC
        
        
        // Do any additional setup after loading the view.
//        currencyPairListSelector.pullsDown = false
        currencyPairListSelector.removeAllItems()
        currencyPairListSelector.addItems(withTitles: currencyPairList)
        currencyPairListSelector.selectItem(withTitle: currencyPairSetting)
        // make sure that currencyPairSetting is always in the array currencyPairList
        
        
        
        
    }
    
}


