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
import Swamp


class HomeScreenVC: NSViewController, NSTableViewDataSource, SwampSessionDelegate {
    
    
    // Live Data Elements
    let tickerNotificationName = Notification.Name(rawValue:tickerUpdatedNotificationKey)
    let orderBookNotificationName = Notification.Name(rawValue:orderBookAndTradesUpdatedNotificationKey)
    var currencyPairSetting = "USDT_ETH"
    var tickr : LiveTicker = LiveTicker(currencyPair: "", last: 0, lowestAsk: 0, highestBid: 0, percentChange: 0, baseVolume: 0, quoteVolume: 0, isFrozen: false, twentyFourHrHigh: 0, twentyFourHrLow: 0)
    var ordrBk : LiveOrderBook = LiveOrderBook(currencyPair: "", rate: 0, type: "", amount: 0)
    let swampSession = SwampSession(realm: "realm1", transport: WebSocketSwampTransport(wsEndpoint:  URL(string: "wss://api.poloniex.com")!))
    @IBOutlet weak var tickerLabel: NSTextField!
    
    
    
    
    var openOrders: [OpenOrder] = []
        //[OpenOrder(currencyPair:"", orderNumber:0, type:"buy", rate:0, amount:0, total:0)]
    var openOrdersString : [String] = []
    
    @IBAction func cancelButtonPressed(_ sender: NSButton) {
        if openOrders.count != 0 {
            let v = sender.superview as! NSView
            let tV = sender.superview?.superview?.superview as! NSTableView
            let row = tV.row(for: v)
            let orderNumber = openOrders[row].orderNumber
            var cancelled:Bool, message:String, amount:Double
            (cancelled , message, amount) = MyOrderCancelLoader.cancelOrder(orderNumber: orderNumber!, keys!)
            print ("message: %@", message)
            let coin = openOrders[row].currencyPair?.components(separatedBy: "_")[1] as! String
            if cancelled {
                print ("order number \(orderNumber!) for \(amount) \(coin) successfuly cancelled")
                openOrdersString.remove(at: row)
                openOrdersTableView.reloadData()
            } else {
                print("there has been a mistake cancelling the order number \(orderNumber) for \(amount) \(coin)")
            }
        }
        else {print ("no open orders to cancel")
        }
    }

    @IBOutlet weak var openOrdersTableView: NSTableView!
    
    var keys: APIKeys?
    var timer = Timer()
    var vc: NSViewController = NSViewController()

    
    @IBAction func APIKeysButtonPressed(_ sender: NSButton) {
        showAuthenticationVCasSheet ()
    }
    
    @IBAction func settingsButtonPressed(_ sender: NSButton) {
        showSettingsVCasSheet ()
    }
    
    @IBOutlet weak var APIKeysButton: NSButton!
    @IBOutlet weak var settingsButton: NSButton!
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
        
        
        // Swamp connection to Poloniex Push Api
        self.swampSession.delegate = self
        self.swampSession.connect()
        
        // Initiating the observers system
        createObservers()
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
        print("view will dissapear")

        timer.invalidate()
        print("disconnecting Swamp session")
        self.swampSession.disconnect("")
    }

    
// View Controller Management
    func showAuthenticationVCasSheet () {
        self.APIKeysButton.isEnabled=false
        let destVC = storyBoard.instantiateController(withIdentifier: "authenticationViewController") as! AuthenticationVC
        destVC.keys = KeyLoader.loadKeys(keychainKeyPublicKey, keychainKeySecretKey) ?? APIKeys(key: "", secret: "")

        self.presentViewControllerAsSheet(destVC)
    }
    
    func showSettingsVCasSheet () {
        self.settingsButton.isEnabled=false
        let destVC = storyBoard.instantiateController(withIdentifier: "settingsViewController") as! NSTabViewController
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
    
    
    
    // Open Orders View
    func updateOpenOrdersTableView () {
        var e = ""
        (openOrders, e) = OpenOrdersLoader.returnOpenOrders(currencyPair:"all", keys!)
        var response : [String] = []
        var buttons : [String] = []
        if openOrders.count==0 {
            response = ["No open orders."]
            openOrdersTableView.tableColumns[0].isHidden = true
        }
        else {
            openOrdersTableView.tableColumns[0].isHidden = false
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
    
    
    
    
    // SWAMP stuff
    
    func swampSessionHandleChallenge(_ authMethod: String, extra: [String : Any])-> String {
        print("authMethod is " + authMethod)
        for (key, value) in extra {
            print ("first element in the extra parameter is: " + key + (value as! String) )
        }
        return "data handled"
    }
    
    func swampSessionConnected(_ session: SwampSession, sessionId: Int) {
        print ("Swamp session connected, ID : \(sessionId)")
        
        // Subscribe to ticker
        session.subscribe("ticker", options: ["disclose_me": true],
                          onSuccess: { subscription in
                            print ("subscribe successful")
                            // subscription can be stored for subscription.cancel()
        }, onError: { details, error in print ("error subscribing:" + error)
            // handle error
        }, onEvent: { details, results, kwResults in
            let cp = results?[0] as! String
            if cp == self.currencyPairSetting {
                self.tickr = LiveTicker(currencyPair: (results?[0] as! String), last: Double(results?[1] as! String)!, lowestAsk: Double(results?[2] as! String)!, highestBid: Double(results?[3] as! String)!, percentChange: Double(results?[4] as! String)!, baseVolume: Double(results?[5] as! String)!, quoteVolume: Double(results?[6] as! String)!, isFrozen: (results?[7] as! Bool), twentyFourHrHigh: Double(results?[8] as! String)!, twentyFourHrLow: Double(results?[9] as! String)!)
                NotificationCenter.default.post(name: self.tickerNotificationName, object: nil)
            }
        })
        
//        // Subscribe to currency pair order book and trades
//        session.subscribe(currencyPairSetting, options: ["disclose_me": true],
//                          onSuccess: { subscription in
//                            print ("subscribe to \(self.currencyPairSetting) successful")
//                            // subscription can be stored for subscription.cancel()
//        }, onError: { details, error in print ("error subscribing:" + error)
//            // handle error
//        }, onEvent: { details, results, kwResults in
//            print ("orderBook update received")
//            
//            self.processOrderData (kwResults, results!)
//            
//        })
        
//        
//                        self.tickr = Ticker(currencyPair: (results?[0] as! String), last: Double(results?[1] as! String)!, lowestAsk: Double(results?[2] as! String)!, highestBid: Double(results?[3] as! String)!, percentChange: Double(results?[4] as! String)!, baseVolume: Double(results?[5] as! String)!, quoteVolume: Double(results?[6] as! String)!)
        
        
        // Event data is usually in results, but manually check blabla yadayada
        
        
    }
    
    func swampSessionEnded(_ reason: String){
        print ("Session ended for the reason: " + reason)
        print(reason)
        let reasonSummary = reason.components(separatedBy: "\"")[1]
        switch  reasonSummary {
        case "Invalid HTTP upgrade":
            print("trying to reconnect due to %@", reasonSummary)
            self.swampSession.connect()
        default: break
        }
    }
    
    
    // Live Data update Functions
    func updateTickerLabel (notification: NSNotification) {
        print ("New Price: \(self.tickr.last)")
        let str = "New Price: \(self.tickr.last)"
        let textView = NSTextView(frame: NSMakeRect(0, 0, 100, 100))
        let attributes = [NSForegroundColorAttributeName: NSColor.red]
        let attrStr = NSMutableAttributedString(string: str, attributes: attributes)
        let area = NSMakeRange(0, attrStr.length)
        if let font = NSFont(name: "Helvetica Neue Light", size: 16) {
            attrStr.addAttribute(NSFontAttributeName, value: font, range: area)
            textView.textStorage?.append(attrStr)
        }
        tickerLabel.attributedStringValue = attrStr
        
//        let i = averageTicker.add(number: self.tickr.last)
//        let movingPointAverage = averageTicker.movingPointAverage(numberOfRecentElementsToAverage: movingAverageSize, dataSize: i)
//        let relativeDifference : Double = 100*(self.tickr.last/movingPointAverage - 1)
//        print ("MPA: \(movingPointAverage)")
//        print ("rel diff: \(relativeDifference)")
//        print ("rel diff: \(self.tickr.percentChange)")
//        var pitch = pitchMean + relativeDifference*pitchDeviation
//        if pitch.isLess(than: 0) {pitch = 1}
//        playAudioWithVariablePitch (pitch: pitch)
//        print ("pitch: \(pitch)")
//        self.lastLabel.text = String(self.tickr.last) //update the screen ticker
    }
    

    
    
    
    // General functions
    func createObservers() {
        // ticker update observer
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreenVC.updateTickerLabel(notification:)), name: tickerNotificationName, object: nil)
    }
    
    
    
    
    
    
}
