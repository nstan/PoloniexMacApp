//
//  PoloniexPublicAPIs.swift
//  Poloniex2
//
//  Created by Nikola Stan on 7/19/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import Foundation

/* RETURN TICKER 
 Returns the ticker for all markets.*/

let requestDelayTime = 3000 /* in milliseconds*/

public struct Ticker: CustomStringConvertible {
    var currencyPair: String
    var last: Double
    var lowestAsk: Double
    var highestBid: Double
    var percentChange: Double
    var baseVolume: Double
    var quoteVolume: Double
    public var description: String {
        return "\(currencyPair): \(last)"
    }
}

public struct TickerLoader {
    public static func returnTicker () -> [Ticker] {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let PoloniexRequest = PoloniexRequestPublic(params: ["command": "returnTicker"])
        let request = PoloniexRequest.urlRequest
        var finished = false
        var tickers = [Ticker]()
        let tickersTask = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
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
                let dict: [AnyHashable: Any?] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as! [AnyHashable: Any?]
                for (key, value) in dict {
                    guard let key = key as? String, let value = value as? [AnyHashable: Any?],
                    let lst = Double((value["last"] as? String)!),
                    let la = Double((value["lowestAsk"] as? String)!),
                    let hb = Double((value["highestBid"] as? String)!),
                    let pc = Double((value["percentChange"] as? String)!),
                    let bv = Double((value["baseVolume"] as? String)!),
                    let qv = Double((value["quoteVolume"] as? String)!)  else {continue}
                    let ticker = Ticker(currencyPair: key, last: lst, lowestAsk: la, highestBid: hb, percentChange: pc, baseVolume: bv, quoteVolume: qv)
                    tickers.append(ticker)
                    print(ticker)
                }
            } catch {
                print("couldn't decode JSON")
                finished = true
                return
            }
            finished = true
        })
        DispatchQueue.global(qos: .userInitiated).async {
            session.resumeAfter(requestDelayTime, tickersTask)
        }
        while(!finished) {}
        print ("Task completed at time: " + String(describing: DispatchTime.now()))
        return tickers
    }
}


/* return 24 Volume
 Returns the 24-hour volume for all markets, plus totals for primary currencies. */

public struct Volume24: CustomStringConvertible {
    var currencyPair: String
    var currency1: String
    var currency1Volume: Double
    var currency2: String
    var currency2Volume: Double
    public var description: String {
        return "\(currencyPair) Volume: \(currency1):\(currency1Volume), \(currency2):\(currency2Volume)"
    }
}

public struct Total: CustomStringConvertible {
    var currency: String
    var total: Double
    public var description: String {
        return "Total \(currency): \(total)"
    }
}

public struct Volume24Loader {
    public static func return24Volume () -> (volumes: [Volume24], totals: [Total]) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let PoloniexRequest = PoloniexRequestPublic(params: ["command": "return24hVolume"])
        let request = PoloniexRequest.urlRequest
        var finished = false
        var volume24s = [Volume24]()
        var totals = [Total]()
        let volume24Task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
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
                let dict: [AnyHashable: Any?] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as! [AnyHashable: Any?]
                for (key, value) in dict {
                    guard let key = key as? String
                        else {continue}
                    if key.hasPrefix("total") {
                        guard let value = value as? String
                            else {continue}
                        let total = Total(currency: key.replacingOccurrences(of: "total", with: "", options: [], range: nil), total: Double(value as String!)!)
                        totals.append(total)
                        print(total)
                    }
                    else {
                        guard let value = value as? [AnyHashable: Any?]
                            else {continue}
                        let currencies = key.components(separatedBy: "_")
                        let amount1 = value[currencies[0]] as! String
                        let amount2 = value[currencies[1]] as! String
                        if currencies.count==2 {
                            let volume24 = Volume24 (currencyPair: key, currency1: currencies[0], currency1Volume: Double(amount1)!, currency2: currencies[1], currency2Volume: Double(amount2)!)
                        volume24s.append(volume24)
                        }
                        else { print ("Error finding currencies identifiers")
                        }
                    }
                }
            } catch {
                print("couldn't decode JSON")
                finished = true
                return
            }
            finished = true
        })
        DispatchQueue.global(qos: .userInitiated).async {
            session.resumeAfter(requestDelayTime, volume24Task)
        }
        while(!finished) {}
        return (volumes: volume24s, totals: totals)
    }
}


/* returnOrderBook 
 Returns the order book for a given market, as well as a sequence number for use with the Push API and an indicator specifying whether the market is frozen. You may set currencyPair to "all" to get the order books of all markets. */

public struct OrderBook: CustomStringConvertible {
    var currencyPair: String?
    var asks: [Order]?
    var bids: [Order]?
    var isFrozen: Bool?
    var seq: Int?
    public var description: String {
        return "\(currencyPair ?? "") order Book"
    }
}

public struct Order: CustomStringConvertible {
    var price: Double?
    var quantity: Double?
    public var description: String {
        return "\(quantity ?? 0) at \(price ?? 0) "
    }

}


public struct OrderBookLoader {
    public static func returnOrderBook (currencyPair: String, depth: Int?) -> ([OrderBook]) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let PoloniexRequest = PoloniexRequestPublic(params: ["command": "returnOrderBook", "currencyPair": currencyPair, "depth": String(depth!)])
        let request = PoloniexRequest.urlRequest
        var finished = false
        var orderBooks = [OrderBook]()
        let orderBookTask = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
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
                let dict: [AnyHashable: Any?] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as! [AnyHashable: Any?]
                var oB: OrderBook = OrderBook()
                if currencyPair != "all" {
                    oB.currencyPair = currencyPair
                    let a = dict["asks"] as? [AnyObject]
                    var o = Order()
                    for x in a! {
                        o = Order()
                        o.price = Double((x[0] as? String)!)
                        o.quantity = x[1] as? Double
                        oB.asks?.append(o)
                    }
                    let b = dict["bids"] as? [AnyObject]
                    for x in b! {
                        o = Order()
                        o.price = Double((x[0] as? String)!)
                        o.quantity = x[1] as? Double
                        oB.bids?.append(o)
                    }
                    oB.isFrozen = Bool((dict["isFrozen"] as! String) != "0")
                    oB.seq = dict["seq"] as? Int
                    orderBooks.append(oB)
                } else {
                    for (key, value) in dict {
                        oB = OrderBook()
                        guard let key = key as? String else {continue}
                        oB.currencyPair = key
                        guard let value = value as? [AnyHashable: Any?] else {continue}
                        let a = value["asks"] as? [[AnyObject]]
                        var o = Order()
                        var os = [Order]()
                        for x in a! {
                            o = Order()
                            o.price = Double((x[0] as? String)!)
                            o.quantity = x[1] as? Double
                            os.append(o)
                        }
                        oB.asks = os
                        let b = value["bids"] as? [[AnyObject]]
                        os = [Order]()
                        for x in b! {
                            o = Order()
                            o.price = Double((x[0] as? String)!)
                            o.quantity = x[1] as? Double
                            os.append(o)
                        }
                        oB.bids = os
                        oB.isFrozen = Bool((value["isFrozen"] as! String) != "0")
                        oB.seq = value["seq"] as? Int
                        orderBooks.append(oB)
                    }
                }
            } catch {
                print("couldn't decode JSON")
                finished = true
                return }
            finished = true
        })
        DispatchQueue.global(qos: .userInitiated).async {
            session.resumeAfter(requestDelayTime, orderBookTask)
        }
        while(!finished) {}
        return orderBooks
    }
}

/* returnTradeHistory 
 Returns the past 200 trades for a given market, or up to 50,000 trades between a range specified in UNIX timestamps by the "start" and "end" GET parameters.*/

public struct Trade: CustomStringConvertible {
    var currencyPair: String?
    var globalTradeID: Int?
    var tradeID: Int?
    var date: Date?
    var type: String?
    var rate: Double?
    var amount: Double?
    var total: Double?
    var fee: Double?
    var orderNumber: Int?
    var category: String?
    public var description: String {
        return "\(String(describing: type)) \(String(describing: amount)) at the rate of \(String(describing: amount))"
    }
}


public struct TradeHistoryLoader {
    public static func returnTradeHistory (currencyPair: String, start: Date, end: Date) -> ([Trade]) {
        /* currency pair is required and cannot be set to "all", start and end are specified in UNIX timestamps and if leftout the response gives a default time range*/
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let startUTC = start.timeIntervalSince1970
        let endUTC = end.timeIntervalSince1970
        let PoloniexRequest = PoloniexRequestPublic(params: ["command": "returnTradeHistory", "currencyPair": currencyPair, "start": String(startUTC), "end": String(endUTC)])
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
                let dict: [[AnyHashable: Any?]] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as!  [[AnyHashable: Any?]]
                for x in dict {
                    var tH: Trade = Trade()
                    tH.currencyPair = currencyPair
                    tH.globalTradeID = x["globalTradeID"] as? Int
                    tH.tradeID = x["tradeID"] as? Int
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatter.timeZone = TimeZone(identifier: "UTC")
                    tH.date = formatter.date(from: (x["date"] as? String)!)
                    
                    tH.type = x["type"] as? String
                    tH.rate = Double((x["rate"] as? String)!)
                    tH.amount = Double((x["amount"] as? String)!)
                    tH.total = Double((x["total"] as? String)!)
                    tradeHistories.append(tH)
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


/* returnChartData
 Returns candlestick chart data. Required GET parameters are "currencyPair", "period" (candlestick period in seconds; valid values are 300, 900, 1800, 7200, 14400, and 86400), "start", and "end". "Start" and "end" are given in UNIX timestamp format and used to specify the date range for the data returned. */

public struct ChartData: CustomStringConvertible {
    var date: Date?
    var high: Double?
    var low: Double?
    var open: Double?
    var close: Double?
    var volume: Double?
    var quoteVolume: Double?
    var weightedAverage: Double?
    public var description: String {
        return "On \(date) closed with \(close) with a high of \(high) and a low of \(low)"
    }
}


public struct ChartDataLoader {
    public static func returnChartData (currencyPair: String, start: Date, end: Date, period: Int) -> ([ChartData]) {
        /* currency pair is required and cannot be set to "all", start and end are specified in UNIX timestamps and if leftout the response gives a default time range*/
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let startUTC = start.timeIntervalSince1970
        let endUTC = end.timeIntervalSince1970
        let PoloniexRequest = PoloniexRequestPublic(params: ["command": "returnChartData", "currencyPair": currencyPair, "start": String(startUTC), "end": String(endUTC), "period": "\(period)"])
        let request = PoloniexRequest.urlRequest
        var finished = false
        var chartDatas = [ChartData]()
        let chartDataTask = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
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
                let dict: [[AnyHashable: Any?]] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as!  [[AnyHashable: Any?]]
                for x in dict {
                    var cD: ChartData = ChartData()
                    let d = (x["date"] as? Double)?.getDateStringFromUTC()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatter.timeZone = TimeZone.autoupdatingCurrent
                    cD.date = formatter.date(from: d!)!
                    cD.high = x["high"] as? Double
                    cD.low = x["low"] as? Double
                    cD.open = x["open"] as? Double
                    cD.close = x["close"] as? Double
                    cD.volume = x["volume"] as? Double
                    cD.quoteVolume = x["quoteVolume"] as? Double
                    cD.weightedAverage = x["weightedAverage"] as? Double
                    chartDatas.append(cD)
                }
            } catch {
                print("couldn't decode JSON")
                finished = true
                return }
            finished = true
        })
        DispatchQueue.global(qos: .userInitiated).async {
            session.resumeAfter(requestDelayTime, chartDataTask)
        }
        while(!finished) {}
        return chartDatas
    }
}


/* returnCurrencies
 Returns candlestick chart data. Required GET parameters are "currencyPair", "period" (candlestick period in seconds; valid values are 300, 900, 1800, 7200, 14400, and 86400), "start", and "end". "Start" and "end" are given in UNIX timestamp format and used to specify the date range for the data returned. */

public struct Currency: CustomStringConvertible {
    var currencyAbbrev: String?
    var currencyName: String?
    var currencyId: Int?
    var txFee: Double?
    var minConf: Int?
    var depositAddress: String?
    var disabled: Bool?
    var delisted: Bool?
    var frozen: Bool?
    public var description: String {
        return "\(currencyName ?? "nil") (\(currencyAbbrev ?? "nil")) deposit address: \(depositAddress ?? "nil")"
    }
}


public struct CurrenciesLoader {
    public static func returnCurrencies () -> ([Currency]) {
        /* currency pair is required and cannot be set to "all", start and end are specified in UNIX timestamps and if leftout the response gives a default time range*/
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let PoloniexRequest = PoloniexRequestPublic(params: ["command": "returnCurrencies"])
        let request = PoloniexRequest.urlRequest
        var finished = false
        var currencies = [Currency]()
        let currenciesTask = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
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
                    var c: Currency = Currency()
                    guard let key = key as? String, let value = value as? [AnyHashable: Any?] else {continue}
                    c.currencyAbbrev = key
                    c.currencyId = value ["id"] as? Int
                    c.currencyName = value["name"] as? String
                    c.txFee = Double((value["txFee"] as? String!)!)
                    c.minConf = value["minConf"] as? Int!
                    c.depositAddress = value["depositAddress"] as? String ?? ""
                    c.disabled = value["disabled"] as? Bool
                    c.delisted = value["delisted"] as? Bool
                    c.frozen = value["frozen"] as? Bool
                    currencies.append(c)
                }
            } catch {
                print("couldn't decode JSON")
                finished = true
                return }
            finished = true
        })
        DispatchQueue.global(qos: .userInitiated).async {
            session.resumeAfter(requestDelayTime, currenciesTask)
        }
        while(!finished) {}
        return currencies
    }
}


/* returnLoanOrders
 Returns the list of loan offers and demands for a given currency, specified by the "currency" GET parameter. */

/* No implementation yet */
