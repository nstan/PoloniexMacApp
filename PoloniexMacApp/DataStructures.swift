//
//  DataStructures.swift
//  Poloniex
//
//  Created by Nikola Stan on 8/9/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import Foundation

public struct LiveTicker: CustomStringConvertible {
    var currencyPair: String
    var last: Double
    var lowestAsk: Double
    var highestBid: Double
    var percentChange: Double
    var baseVolume: Double
    var quoteVolume: Double
    var isFrozen: Bool?
    var twentyFourHrHigh: Double?
    var twentyFourHrLow: Double?
    public var description: String {
        return "\(currencyPair): \(last)"
    }
}

public struct LiveOrderBook: CustomStringConvertible {
    var currencyPair: String?
    var rate: Double?
    var type: String?
    var amount: Double?
    public var description: String {
        return "\(currencyPair ?? "") order Book"
    }
}

public struct LiveTrade: CustomStringConvertible {
    var currencyPair: String?
    var tradeID: Int?
    var rate: Double?
    var amount: Double?
    var date: Date?
    var total: Double?
    var type: String?

    public var description: String {
        return "\(String(describing: type)) \(String(describing: amount)) at the rate of \(String(describing: amount))"
    }
}
