//
//  Extensions.swift
//  Poloniex2
//
//  Created by Nikola Stan on 7/22/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import Foundation
import Dispatch

public extension URLSession {
    
    func resumeAfter(_ delayIn_ms : Int,_ task: URLSessionDataTask)
    {
        var timeNow : DispatchTime = DispatchTime.now()
        while lastRequestTime>(timeNow - DispatchTimeInterval.seconds(minTimeBetweenRequest)) {
            timeNow = DispatchTime.now()
        }
        task.resume()
    }
}

public extension Double {
    func getDateStringFromUTC() -> String {
        let date = Date(timeIntervalSince1970: self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: date)
    }
    
    func relativeDifference (changedValue: Double) -> Double {
        let relDiff = 100*(changedValue - self)/self
        return relDiff
    }
    
}

public extension Date {
    
    func getUTC() -> Double {
        
        let UTC = self.timeIntervalSince1970
        return UTC
    }
}


public extension Array {
    
    func shift(withDistance distance: Int = 1) -> Array<Element> {
        let offsetIndex = distance >= 0 ?
            self.index(startIndex, offsetBy: distance, limitedBy: endIndex) :
            self.index(endIndex, offsetBy: distance, limitedBy: startIndex)
        
        guard let index = offsetIndex else { return self }
        return Array(self[index ..< endIndex] + self[startIndex ..< index])
    }
    
    mutating func shiftInPlace(withDistance distance: Int = 1) {
        self = shift(withDistance: distance)
    }
    
}

public extension Array where Element == Double {
    
    mutating func add(number: Double) -> Int
    {
        var i:Int
        i = self.index(where: { $0 == 0 }) ?? -1
        if i == -1 {
            self = self.shift(withDistance: 1)
            i = (liveFeedSize-1)
        }
        self[i]=number
        return i+1 //returns the size of the collected data in the array
    }
    
    func movingPointAverage (numberOfRecentElementsToAverage : Int, dataSize: Int) -> Double {
        var n:Int
        if numberOfRecentElementsToAverage > dataSize {
            print ("Error: can't average more elements than contained in the data, reducing averaging length to data size.")
            n = dataSize
        } else {
            n = numberOfRecentElementsToAverage
        }
        let mpa = self[dataSize-n...dataSize-1].reduce(0, +)/Double(n)
        return mpa
    }
    
}

