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


class HomeScreenVC: NSViewController, NSTableViewDataSource {
    
    var openOrders: [OpenOrder] = []
        //[OpenOrder(currencyPair:"", orderNumber:0, type:"buy", rate:0, amount:0, total:0)]
    var openOrdersString : [String] = []
    var cancelButtons : [String] = []
    
    @IBOutlet weak var openOrdersTableView: NSTableView!
    
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
        
//        openOrdersTableView.delegate = self

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
    
    // MARK: DataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return openOrdersString.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//        let c0 = NSTableColumn.init(identifier: "openOrdersDescriptionColumn")
//        let c1 = NSTableColumn.init(identifier: "openOrdersButtonsColumn")
//        guard let tc = tableColumn else {
//            print ("error reading table column");
//            return ""
//        }
//        switch tc {
//        case c0:
            return openOrdersString[row]
//        case c1:
//            return cancelButtons[row]
//        default :
//            return ""
//        }
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
        updateOpenOrdersTableView ()
    }
    
    func updateOpenOrdersTableView () {
        var e = ""
        (openOrders, e) = OpenOrdersLoader.returnOpenOrders(currencyPair:"all", keys!)
        var response : [String] = []
        var buttons : [String] = []
        if openOrders.count==0 {response = ["No open orders."]}
        else {
            for x in openOrders {
                let c0 = x.currencyPair!.components(separatedBy: "_")[0]
                let c1 = x.currencyPair!.components(separatedBy: "_")[1]
                response.append(String.localizedStringWithFormat("%@ %.3f %@ at %.2f %@/%@\n", x.type!.uppercased(), x.amount!, c1, x.rate!, c0, c1))
                buttons.append(c1)
            }
        }
        if !e.isEmpty {
            openOrdersString = [e];
//            cancelButtons = []
        }
        else {
            openOrdersString = response
//            cancelButtons = buttons
        }
        openOrdersTableView.reloadData()
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
