//
//  NetworkRequests.swift
//  NetworkStack
//
//  Created by Ben Norris on 2/8/16.
//  Copyright © 2016 OC Tanner. All rights reserved.
//

import Foundation
import Marshal

public protocol NetworkRequests {
    func get(endpoint: String, parameters: JSONObject?, preventCaching: Bool, completion: Network.ResponseCompletion)
    func post(endpoint: String, parameters: JSONObject?, completion: Network.ResponseCompletion)
    func patch(endpoint: String, parameters: JSONObject?, completion: Network.ResponseCompletion)
    func put(endpoint: String, parameters: JSONObject?, completion: Network.ResponseCompletion)
    func delete(endpoint: String, completion: Network.ResponseCompletion)
}

public struct NetworkAPIRequests: NetworkRequests {

    // MARK: - Public initializer

    public init() { }

    
    // MARK: - Internal properties
    
    var network = Network()
    
    
    // MARK: - Private properties
    
    private var defaultConfiguration: NSURLSessionConfiguration? {
        guard let appNetworkState = AppNetworkState.currentAppState else { return nil }
        guard let accessToken = appNetworkState.accessToken else { return nil }
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = ["content-type": "application/json", "Authorization": "Bearer \(accessToken)"]
        configuration.timeoutIntervalForRequest = 10.0
        return configuration
    }
    
    
    // MARK: - Public API
    
    public func get(endpoint: String, parameters: JSONObject?, preventCaching: Bool = false, completion: Network.ResponseCompletion) {
        do {
            let (session, url) = try config(endpoint)
            network.get(url, session: session, parameters: parameters, completion: completion)
        }
        catch {
            completion(.Error(error))
        }
    }
    
    public func post(endpoint: String, parameters: JSONObject?, completion: Network.ResponseCompletion) {
        do {
            let (session, url) = try config(endpoint)
            network.post(url, session: session, parameters: parameters, completion: completion)
        }
        catch {
            completion(.Error(error))
        }
    }
    
    public func patch(endpoint: String, parameters: JSONObject?, completion: Network.ResponseCompletion) {
        do {
            let (session, url) = try config(endpoint)
            network.patch(url, session: session, parameters: parameters, completion: completion)
        }
        catch {
            completion(.Error(error))
        }
    }
    
    public func put(endpoint: String, parameters: JSONObject?, completion: Network.ResponseCompletion) {
        do {
            let (session, url) = try config(endpoint)
            network.put(url, session: session, parameters: parameters, completion: completion)
        }
        catch {
            completion(.Error(error))
        }
    }
    
    public func delete(endpoint: String, completion: Network.ResponseCompletion) {
        do {
            let (session, url) = try config(endpoint)
            network.delete(url, session: session, completion: completion)
        }
            
        catch {
            completion(.Error(error))
        }
    }
    
}


// MARK: - Private functions

private extension NetworkAPIRequests {
    
    /// - Precondition: `AppNetworkState.currentAppState` must not be nil
    func config(endpoint: String, preventCaching: Bool = false) throws -> (session: NSURLSession, url: NSURL) {
        guard let appNetworkState = AppNetworkState.currentAppState else { fatalError("Must configure current app state to config") }
        guard let configuration = defaultConfiguration else { throw Network.Error.Status(status: 401) }
        if preventCaching {
            configuration.URLCache = nil
        }
        let session = NSURLSession(configuration: configuration)
        guard let url = appNetworkState.urlForEndpoint(endpoint) else { throw Network.Error.MalformedEndpoint(endpoint: endpoint) }
        return (session, url)
    }
    
}
