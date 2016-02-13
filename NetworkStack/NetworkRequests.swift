//
//  NetworkRequests.swift
//  NetworkStack
//
//  Created by Ben Norris on 2/8/16.
//  Copyright © 2016 OC Tanner. All rights reserved.
//

import Foundation
import JaSON

public protocol NetworkRequests {
    func get(endpoint: String, parameters: JSONObject?, completion: (responseObject: JSONObject?, error: ErrorType?) -> Void) throws
    func post(endpoint: String, parameters: JSONObject?, completion: (responseObject: JSONObject?, error: ErrorType?) -> Void) throws
    func patch(endpoint: String, parameters: JSONObject?, completion: (responseObject: JSONObject?, error: ErrorType?) -> Void) throws
    func put(endpoint: String, parameters: JSONObject?, completion: (responseObject: JSONObject?, error: ErrorType?) -> Void) throws
    func delete(endpoint: String, completion: (responseObject: JSONObject?, error: ErrorType?) -> Void) throws
}

public struct NetworkAPIRequests: NetworkRequests {
    
    // MARK: - Initializers
    
    public init(appState: AppStateRepresentable) {
        self.appState = appState
    }
    
    
    // MARK: - Internal properties
    
    var network = Network()
    
    
    // MARK: - Private properties
    
    private let appState: AppStateRepresentable
    private var defaultSession: NSURLSession? {
        guard let accessToken = appState.accessToken else { return nil }
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["content-type": "application/json", "Authorization": "Bearer \(accessToken)"]
        configuration.timeoutIntervalForRequest = 10.0
        return NSURLSession(configuration: configuration)
    }
    
    
    // MARK: - Public API
    
    public func get(endpoint: String, parameters: JSONObject?, completion: (responseObject: JSONObject?, error: ErrorType?) -> Void) throws {
        let (session, url) = try config(endpoint)
        network.get(url, session: session, parameters: parameters, completion: completion)
    }
    
    public func post(endpoint: String, parameters: JSONObject?, completion: (responseObject: JSONObject?, error: ErrorType?) -> Void) throws {
        let (session, url) = try config(endpoint)
        network.post(url, session: session, parameters: parameters, completion: completion)
    }
    
    public func patch(endpoint: String, parameters: JSONObject?, completion: (responseObject: JSONObject?, error: ErrorType?) -> Void) throws {
        let (session, url) = try config(endpoint)
        network.patch(url, session: session, parameters: parameters, completion: completion)
    }
    
    public func put(endpoint: String, parameters: JSONObject?, completion: (responseObject: JSONObject?, error: ErrorType?) -> Void) throws {
        let (session, url) = try config(endpoint)
        network.put(url, session: session, parameters: parameters, completion: completion)
    }
    
    public func delete(endpoint: String, completion: (responseObject: JSONObject?, error: ErrorType?) -> Void) throws {
        let (session, url) = try config(endpoint)
        network.delete(url, session: session, completion: completion)
    }
    
}


// MARK: - Private functions

private extension NetworkAPIRequests {
    
    func config(endpoint: String) throws -> (session: NSURLSession, url: NSURL) {
        guard let session = defaultSession else { throw Network.Error.AuthenticationRequired }
        guard let url = NSURL(string: appState.networkPath + endpoint) else { throw Network.Error.InvalidEndpoint }
        return (session, url)
    }
    
}
