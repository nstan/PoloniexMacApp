//
//  Constants.swift
//  Poloniex
//
//  Created by Nikola Stan on 8/7/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

// General app Functional constants
let keychainKeyPublicKey = "publicKey"
let keychainKeySecretKey = "secretKey"

let updateSynchronousDataAfterSeconds:Int = 60
let updateSynchronousDataAfterSecondsTolerance:Int = 30
let minTimeBetweenRequest:Int = 1
let tickerUpdatedNotificationKey = "nikolastan.com.tickerUpdated"
let orderBookAndTradesUpdatedNotificationKey = "nikolastan.com.orderBookUpdated"

let tickerUpdatePriceChangeThreshold = 0.2

let pitchMean:Double = 1000
let pitchDeviation:Double = 10000

let liveFeedSize:Int = 50
let movingAverageSize:Int = 10 //this value must be less than the liveFeedSize

let priceChangeSlashTradePressureSetting:Bool = true //true means that sound notification will indicate price chage relative to averaged price, false goes for the pressure of buys and sell trades


