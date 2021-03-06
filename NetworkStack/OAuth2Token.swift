//
//  OAuth2Token.swift
//  NetworkStack
//
//  Created by Ben Norris on 2/11/16.
//  Copyright © 2016 OC Tanner. All rights reserved.
//

import Foundation
import Marshal
import SimpleKeychain

struct OAuth2Token: Unmarshaling {

    let accessToken: String
    let expiresAt: Date
    let refreshToken: String?
    
    private static let keychain = Keychain()
    private static let accessTokenKey = "access_token"
    private static let expiresAtKey = "expires_at"
    private static let expiresInKey = "expires_in"
    private static let refreshTokenKey = "refresh_token"
    
    init(accessToken: String, expiresAt: Date = Date.distantFuture, refreshToken: String? = nil) {
        self.accessToken = accessToken
        self.expiresAt = expiresAt
        self.refreshToken = refreshToken
    }
    
    init(object: MarshaledObject) throws {
        self.accessToken = try object <| OAuth2Token.accessTokenKey
        let expiresIn: TimeInterval = try object <| OAuth2Token.expiresInKey
        self.expiresAt = Date(timeIntervalSinceNow: expiresIn)
        self.refreshToken = try object <| OAuth2Token.refreshTokenKey
    }

    init(key: String) throws {
        let dictionary: MarshaledObject = try OAuth2Token.keychain.valueForKey(OAuth2Token.tokenKey(key))
        
        self.accessToken = try dictionary <| OAuth2Token.accessTokenKey
        self.expiresAt = try dictionary <| OAuth2Token.expiresAtKey
        self.refreshToken = try dictionary <| OAuth2Token.refreshTokenKey
    }
    
    func lock(_ key: String) throws {
        let tokenValues: NSDictionary = [
            OAuth2Token.accessTokenKey: accessToken as AnyObject,
            OAuth2Token.expiresAtKey: expiresAt as AnyObject,
            OAuth2Token.refreshTokenKey: refreshToken as AnyObject? ?? "" as AnyObject
        ]
        try OAuth2Token.keychain.set(tokenValues, forKey: OAuth2Token.tokenKey(key))
    }

    static func delete(_ key: String) {
        OAuth2Token.keychain.deleteValue(forKey: tokenKey(key))
    }
    
    private static func tokenKey(_ key: String) -> String {
        return "\(key).token"
    }

}
