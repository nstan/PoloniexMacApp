//
//  PoloniexPrivateAPIs.swift
//  Poloniex2
//
//  Created by Nikola Stan on 7/24/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import Foundation

/* returnBalances
 
 Returns all of your available balances. */

public struct Balance {
    var currencyAbbrev : String
    var currencyAmount : Double
}

public struct BalancesLoader {
    public static func returnBalances (_ keys: APIKeys) -> ([Balance]) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let PoloniexRequest = PoloniexRequestPrivate(params: ["command": "returnBalances"], keys: keys)
        let request = PoloniexRequest.urlRequest
        var finished = false
        var balances = [Balance]()
        let balancesTask = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data, let responseBody = String(data: data, encoding: .utf8) else {
                print("couldn't decode data")
                finished = true
                return
            }
            
            guard error == nil else {
                print("error response")
                print (error as! String)
                finished = true
                return
            }
            
            guard !responseBody.isEmpty else {
                print("empty response")
                finished = true
                return
            }
            do {
                let dict: [AnyHashable: Any?] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as!  [AnyHashable: Any?]
                for (key, value) in dict {
                    var b: Balance = Balance(currencyAbbrev: "", currencyAmount: 0)
                    guard let key = key as? String, let value = value as? String else {continue}
                    b.currencyAbbrev = key
                    b.currencyAmount = Double(value)!
                    balances.append(b)
                }
            } catch {
                print("couldn't decode JSON")
                finished = true
                return }
            finished = true
        })
        DispatchQueue.global(qos: .userInitiated).async {
            session.resumeAfter(requestDelayTime, balancesTask)
        }
        while(!finished) {}
        return balances
    }
}


/* returnCompleteBalances
 
 Returns all of your balances, including available balance, balance on orders, and the estimated BTC value of your balance. By default, this call is limited to your exchange account; set the "account" POST parameter to "all" to include your margin and lending accounts. */

public struct BalanceComplete {
    var currencyAbbrev : String?
    var available : Double?
    var onOrders : Double?
    var btcValue : Double?
}

public struct BalancesCompleteLoader {
    public static func returnCompleteBalances (account: String, _ keys: APIKeys) -> ([BalanceComplete]) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let PoloniexRequest = PoloniexRequestPrivate(params: ["command": "returnCompleteBalances", "account": account], keys: keys)
        let request = PoloniexRequest.urlRequest
        var finished = false
        var balances = [BalanceComplete]()
        let balancesTask = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data, let responseBody = String(data: data, encoding: .utf8) else {
                print("couldn't decode data")
                finished = true
                return
            }
            
            guard error == nil else {
                print("error response")
                print (error as! String)
                finished = true
                return
            }
            
            guard !responseBody.isEmpty else {
                print("empty response")
                finished = true
                return
            }
            do {
                let dict: [AnyHashable: Any?] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as!  [AnyHashable: Any?]
                for (key, value) in dict {
                    var b: BalanceComplete = BalanceComplete()
                    guard let key = key as? String, let value = value as? [AnyHashable: Any?] else {continue}
                    
                    b.currencyAbbrev = key
                    b.available = value["available"] as? Double
                    b.onOrders = value["onOrders"] as? Double
                    b.btcValue = value["btcValue"] as? Double
                    balances.append(b)
                }
            } catch {
                print("couldn't decode JSON")
                finished = true
                return }
            finished = true
        })
        DispatchQueue.global(qos: .userInitiated).async {
            session.resumeAfter(requestDelayTime, balancesTask)
        }
        while(!finished) {}
        return balances
    }
}

/* returnDepositAddresses
Returns all of your deposit addresses. */

/* generateNewAddress
 Generates a new deposit address for the currency specified by the "currency" POST parameter.*/

/* returnDepositsWithdrawals
 Returns your deposit and withdrawal history within a range, specified by the "start" and "end" POST parameters, both of which should be given as UNIX timestamps.*/




/* returnOpenOrders
 Returns your open orders for a given market, specified by the "currencyPair" POST parameter, e.g. "BTC_XCP". Set "currencyPair" to "all" to return open orders for all markets.*/

public struct OpenOrder {
    var currencyPair : String?
    var orderNumber : Int?
    var type : String?
    var rate : Double?
    var amount : Double?
    var total : Double?
}

public struct OpenOrdersLoader {
    public static func returnOpenOrders (currencyPair: String, _ keys: APIKeys) -> ([OpenOrder], errorO: String) {
        var errorO: String = ""
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let PoloniexRequest = PoloniexRequestPrivate(params: ["command": "returnOpenOrders", "currencyPair": currencyPair], keys: keys)
        let request = PoloniexRequest.urlRequest
        var finished = false
        var oOrders = [OpenOrder]()
        let openOrdersTask = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data, let responseBody = String(data: data, encoding: .utf8) else {
                print("couldn't decode data")
                finished = true
                return
            }
            
            guard error == nil else {
                print("error response")
                print (error as! String)
                finished = true
                return
            }
            
            guard responseBody.range(of: "\"error\"") == nil else {
                print(responseBody)
                errorO = responseBody
                finished = true
                return
            }
            
            guard !responseBody.isEmpty else {
                print("empty response")
                finished = true
                return
            }
            do {
                var oO: OpenOrder = OpenOrder()
                if currencyPair != "all" {
                    let dict:[[String: Any?]] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as!  [[String: Any?]]
                    if !dict.isEmpty {
                        for x in dict {
                            oO = OpenOrder()
                            oO.currencyPair = currencyPair;
                            oO.orderNumber = Int((x["orderNumber"] as? String)!)
                            oO.type = x["type"] as? String
                            oO.rate = Double((x["rate"] as? String)!)
                            oO.amount = Double((x["amount"] as? String)!)
                            oO.total = Double((x["total"] as? String)!)
                            oOrders.append(oO)
                        }
                    }
                } else {
                        oO = OpenOrder()
                        if let dict:[String: [[String:Any?]]] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as?  [String: [[String:Any?]]] {
                            for (key, value) in dict {
                                if !value.isEmpty {
                                    for x in value {
                                        oO = OpenOrder()
                                        oO.currencyPair = key
                                        oO.orderNumber = Int((x["orderNumber"] as? String)!)
                                        oO.type = x["type"] as? String
                                        oO.rate = Double((x["rate"] as? String)!)
                                        oO.amount = Double((x["amount"] as? String)!)
                                        oO.total = Double((x["total"] as? String)!)
                                        oOrders.append(oO)
                                    }
                                }
                            }
                        } else {print ("error parsing Json data")}
                }
            } catch {
                print("couldn't decode JSON")
                finished = true
                return }
            finished = true
        })
        DispatchQueue.global(qos: .userInitiated).async {
            session.resumeAfter(requestDelayTime, openOrdersTask)
        }
        while(!finished) {}
        return (oOrders, errorO)
    }
}


/* returnTradeHistory
 Returns your trade history for a given market, specified by the "currencyPair" POST parameter. You may specify "all" as the currencyPair to receive your trade history for all markets. You may optionally specify a range via "start" and/or "end" POST parameters, given in UNIX timestamp format; if you do not specify a range, it will be limited to one day..*/

// Struct TradeHistory is already declared for the Public API command returnTradeHistory

public struct MyTradeHistoryLoader {
    public static func returnTradeHistory (currencyPair: String, start: Date, end: Date, _ keys: APIKeys) -> ([Trade]) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let startUTC = start.timeIntervalSince1970
        let endUTC = end.timeIntervalSince1970
        let PoloniexRequest = PoloniexRequestPrivate(params: ["command": "returnTradeHistory", "currencyPair": currencyPair, "start": String(startUTC), "end": String(endUTC)], keys: keys)
        let request = PoloniexRequest.urlRequest
        var finished = false
        var tradeHistories = [Trade]()
        let tradeHistoryTask = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data, let responseBody = String(data: data, encoding: .utf8) else {
                print("couldn't decode data")
                finished = true
                return
            }
            
            guard error == nil else {
                print("error response")
                print (error as! String)
                finished = true
                return
            }
            
            guard !responseBody.isEmpty else {
                print("empty response")
                finished = true
                return
            }
            do {
                var tH: Trade = Trade()
                if currencyPair != "all" {
                    let dict:[[String: Any?]] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as!  [[String: Any?]]
                    if !dict.isEmpty {
                        for x in dict {
                            tH = Trade()
                            tH.currencyPair = currencyPair;
                            tH.globalTradeID = (x["globalTradeID"] as? Int)!
                            tH.tradeID = Int((x["tradeID"] as? String)!)
                            tH.orderNumber = Int((x["orderNumber"] as? String)!)
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            formatter.timeZone = TimeZone(identifier: "UTC")
                            tH.date = formatter.date(from: (x["date"] as? String)!)
                            tH.type = x["type"] as? String
                            tH.category = x["category"] as? String
                            tH.rate = Double((x["rate"] as? String)!)
                            tH.amount = Double((x["amount"] as? String)!)
                            tH.total = Double((x["total"] as? String)!)
                            tH.fee = Double((x["fee"] as? String)!)
                            tradeHistories.append(tH)
                            
                        }
                    }
                } else {
                    if let dict:[String: [[String:Any?]]] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as?  [String: [[String:Any?]]] {
                        for (key, value) in dict {
                            if !value.isEmpty {
                                for x in value {
                                    tH = Trade()
                                    tH.currencyPair = currencyPair;
                                    tH.globalTradeID = (x["globalTradeID"] as? Int)!
                                    tH.tradeID = Int((x["tradeID"] as? String)!)
                                    tH.orderNumber = Int((x["orderNumber"] as? String)!)
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    formatter.timeZone = TimeZone(identifier: "UTC")
                                    tH.date = formatter.date(from: (x["date"] as? String)!)
                                    tH.type = x["type"] as? String
                                    tH.category = x["category"] as? String
                                    tH.rate = Double((x["rate"] as? String)!)
                                    tH.amount = Double((x["amount"] as? String)!)
                                    tH.total = Double((x["total"] as? String)!)
                                    tH.fee = Double((x["fee"] as? String)!)
                                    tradeHistories.append(tH)
                                }
                            }
                        }
                    } else {print ("error parsing Json data")}
                }
            } catch {
                print("couldn't decode JSON")
                finished = true
                return }
            finished = true
        })
        DispatchQueue.global(qos: .userInitiated).async {
            session.resumeAfter(requestDelayTime, tradeHistoryTask)
        }
        while(!finished) {}
        return tradeHistories
    }
}


/* returnOrderTrades
 Returns all trades involving a given order, specified by the "orderNumber" POST parameter. If no trades for the order have occurred or you specify an order that does not belong to you, you will receive an error. */

// Struct TradeHistory is already declared for the Public API command returnTradeHistory

public struct MyOrderTradesLoader {
    public static func returnOrderTrades (orderNumber: Int, _ keys: APIKeys) -> ([Trade]) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let PoloniexRequest = PoloniexRequestPrivate(params: ["command": "returnOrderTrades", "orderNumber": String(orderNumber)], keys: keys)
        let request = PoloniexRequest.urlRequest
        var finished = false
        var tradeHistories = [Trade]()
        let tradeHistoryTask = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data, let responseBody = String(data: data, encoding: .utf8) else {
                print("couldn't decode data")
                finished = true
                return
            }
            
            guard error == nil else {
                print("error response")
                print (error as! String)
                finished = true
                return
            }
            
            guard responseBody.range(of: "\"error\"") == nil else {
                print(responseBody)
                finished = true
                return
            }
            
            guard !responseBody.isEmpty else {
                print("empty response")
                finished = true
                return
            }
            
            do {
                var tH: Trade = Trade()
                let dict:[[String: Any?]] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as!  [[String: Any?]]
                if !dict.isEmpty {
                    for x in dict {
                        tH = Trade()
                        tH.currencyPair = (x["currencyPair"] as? String)!
                        tH.globalTradeID = (x["globalTradeID"] as? Int)!
                        tH.tradeID = (x["tradeID"] as? Int)!
                        tH.orderNumber = orderNumber
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        formatter.timeZone = TimeZone(identifier: "UTC")
                        tH.date = formatter.date(from: (x["date"] as? String)!)
                        tH.type = x["type"] as? String
                        tH.rate = Double((x["rate"] as? String)!)
                        tH.amount = Double((x["amount"] as? String)!)
                        tH.total = Double((x["total"] as? String)!)
                        tH.fee = Double((x["fee"] as? String)!)
                        tradeHistories.append(tH)
                    }
                }
            } catch {
                print("couldn't decode JSON")
                finished = true
                return }
            finished = true
        })
        DispatchQueue.global(qos: .userInitiated).async {
            session.resumeAfter(requestDelayTime, tradeHistoryTask)
        }
        while(!finished) {}
        return tradeHistories
    }
}


/* cancelOrder
 Cancels an order you have placed in a given market. Required POST parameter is "orderNumber". If successful, the method will return:
 
 {"success":1} */

public struct MyOrderCancelLoader {
    public static func cancelOrder (orderNumber: Int, _ keys: APIKeys) -> (successful: Bool, message: String, amount: Double) {
        var successful:Bool = false
        var message: String = ""
        var amount: Double = 0
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let PoloniexRequest = PoloniexRequestPrivate(params: ["command": "cancelOrder", "orderNumber": String(orderNumber)], keys: keys)
        let request = PoloniexRequest.urlRequest
        var finished = false
        let cancelOrderTask = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data, let responseBody = String(data: data, encoding: .utf8) else {
                print("couldn't decode data")
                finished = true
                return
            }
            
            guard error == nil else {
                print("error response")
                print (error as! String)
                finished = true
                return
            }
            
            guard responseBody.range(of: "\"error\"") == nil else {
                print(responseBody)
                finished = true
                return
            }
            
            guard !responseBody.isEmpty else {
                print("empty response")
                finished = true
                return
            }
            
            do {
                let dict:[String: Any?] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as! [String: Any?]
                successful = (dict["success"] != nil)
                message = dict["message"] as! String
                amount = Double(dict["amount"] as! String)!
            } catch {
                print("couldn't decode JSON")
                finished = true
                return }
            finished = true
        })
        DispatchQueue.global(qos: .userInitiated).async {
            session.resumeAfter(requestDelayTime, cancelOrderTask)
        }
        while(!finished) {}
        return (successful, message, amount)
    }
}

