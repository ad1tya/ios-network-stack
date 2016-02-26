//
//  OAuth2Client.swift
//  NetworkStack
//
//  Created by Tim on 2/24/16.
//  Copyright © 2016 OC Tanner. All rights reserved.
//

import Foundation
import Marshal
import SimpleKeychain

struct OAuth2Client: Unmarshaling {
    
    // MARK: - Error
    
    enum Error: ErrorType {
        case TypeMismatch
    }
    
    
    // MARK: - Internal properties
    
    let id: String
    let secret: String
    
    
    // MARK: - Private properties
    
    private static let keychain = Keychain()
    
    
    // MARK: - Constants
    
    private static let idKey = "client_id"
    private static let secretKey = "client_secret"
    
    
    // MARK: - Initializers
    
    init(id: String, secret: String) {
        self.id = id
        self.secret = secret
    }
    
    init(object: JSONObject) throws {
        self.id = try object <| OAuth2Client.idKey
        self.secret = try object <| OAuth2Client.secretKey
    }
    
    init(key: String) throws {
        let dictionary: MarshaledObject = try OAuth2Client.keychain.valueForKey(OAuth2Client.clientKey(key))
        try self.init(object: dictionary)
    }
    
    
    // MARK: - Public functions
    
    func lock(key: String) throws {
        let clientValues: [String: AnyObject] = [
            OAuth2Client.idKey: id,
            OAuth2Client.secretKey: secret
        ]
        try OAuth2Client.keychain.set(clientValues, forKey: OAuth2Client.clientKey(key))
    }
    
    static func delete(key: String) {
        OAuth2Client.keychain.deleteValue(forKey: clientKey(key))
    }
    
}


// MARK: - Private helper functions

private extension OAuth2Client {
    
    static func clientKey(key: String) -> String {
        return "\(key).oauthClient"
    }
    
}