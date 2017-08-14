//
//  KeyLoader.swift
//  PoloniexMacApp
//
//  Created by Nikola Stan on 8/11/17.
//  Copyright © 2017 Nikola Stan. All rights reserved.
//

import Foundation

public struct APIKeys {
    let key: String
    let secret: String
}

public struct KeyLoader {
    //  keychain should be declared as a global variable in the root of the AppDelegate with this line:
    //        let keychain = KeychainSwift()
    
    public static func loadKeys(_ publicKey: String, _ secretKey: String) -> APIKeys? {

        
        guard let pK = keychain.get(publicKey),
            let sK = keychain.get(secretKey) else {
                print ("No keys stored in keychain")
                return nil
        }
        return APIKeys(key: pK, secret: sK)
    }
    
    public static func clearKeys(_ publicKey: String, _ secretKey: String) {
        keychain.delete(publicKey)
        keychain.delete(secretKey)
    }
    
    
}
