//
//  HomeScreenVC.swift
//  PoloniexMacApp
//
//  Created by Nikola Stan on 8/11/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import Foundation
import Cocoa
import QuartzCore


class HomeScreenVC: NSViewController {
    var keys: APIKeys?
    var timer = Timer()
    var vc: NSViewController = NSViewController()

    
    @IBAction func APIKeysButtonPressed(_ sender: NSButton) {
        showAuthenticationVCasSheet ()
    }
    @IBOutlet weak var APIKeysButton: NSButton!
    @IBOutlet weak var openOrdersLabel: NSTextField!

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initiate the objects in the view
            // set window background color
                self.view.wantsLayer = true
                self.view.layer?.backgroundColor = NSColor.white.cgColor
        
        APIKeysButton.isEnabled = true

        // timer that will refresh the window view
        scheduledTimerWithTimeInterval()

        
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
        updateView ()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func viewWillDisappear() {
        timer.invalidate()
    }

    func showAuthenticationVCasSheet () {
        self.APIKeysButton.isEnabled=false
        let destVC = storyBoard.instantiateController(withIdentifier: "authenticationViewController") as! AuthenticationVC
        destVC.keys = KeyLoader.loadKeys(keychainKeyPublicKey, keychainKeySecretKey) ?? APIKeys(key: "", secret: "")

        self.presentViewControllerAsSheet(destVC)
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(updateSynchronousDataAfterSeconds), target: self, selector: #selector(self.updateView), userInfo: nil, repeats: true)
        timer.tolerance = TimeInterval(updateSynchronousDataAfterSecondsTolerance)
    }
    
    func updateView () {
        updateOpenOrdersLabel ()
        
    }
    
    func updateOpenOrdersLabel () {
        var response : String = "Open Orders: \n"
        var i = 1
        let (oO, e) = OpenOrdersLoader.returnOpenOrders(currencyPair:"all", keys!)
        for x in oO {
            let c0 = x.currencyPair!.components(separatedBy: "_")[0]
            let c1 = x.currencyPair!.components(separatedBy: "_")[1]
            response = response + String.localizedStringWithFormat("%i. %@ %.3f %@ at %.2f %@/%@\n", i, x.type!.uppercased(), x.amount!, c1, x.rate!, c0, c1)
            i=i+1
        }
        var responseTrunc = ""
        if i == 1 {responseTrunc = "No open orders."} else {
            //remove the last new line special character
            let endIndex = response.index(response.endIndex, offsetBy: -1)
            responseTrunc = response.substring(to: endIndex)
        }
        
        openOrdersLabel.preferredMaxLayoutWidth = 400
        openOrdersLabel.maximumNumberOfLines = 5
        
        if !e.isEmpty {
            openOrdersLabel.stringValue = e
        }
        else {
            openOrdersLabel.stringValue = responseTrunc
        }
    }
}
