//
//  Session.swift
//  SwiftGRPCServer
//
//  Created by Kyohei Ito on 2018/06/13.
//  Copyright © 2018年 Google. All rights reserved.
//

import Foundation
import SwiftGRPC
import SwiftProtobuf

public protocol SessionType {
}

public final class Session: SessionType {
    private let server: Server
    private let provider: Provider

    /// Create a server that accepts insecure connections.
    public init(address: String, provider: Provider) {
        gRPC.initialize()
        server = Server(address: address)
        self.provider = provider
    }

    /// Create a server that accepts secure connections.
    public init(address: String, certificateString certificate: String, keyString key: String, provider: Provider) {
        gRPC.initialize()
        server = Server(address: address, key: key, certs: certificate)
        self.provider = provider
    }

    /// Create a server that accepts secure connections.
    public convenience init?(address: String, certificateURL: URL, keyURL: URL, provider: Provider) {
        guard let certificate = try? String(contentsOf: certificateURL, encoding: .utf8),
            let key = try? String(contentsOf: keyURL, encoding: .utf8)
            else { return nil }
        self.init(address: address, certificateString: certificate, keyString: key, provider: provider)
    }

    public enum HandleMethodError: Error {
        case unknownMethod
    }

    /// Start the server.
    public func start() {
        server.run { [weak self] handler in
            guard let me = self else {
                print("ERROR: ServiceServer has been asked to handle a request even though it has already been deallocated")
                return
            }

            guard !handler.completionQueue.hasBeenShutdown else {
                print("ERROR: ServiceServer has been shutdown")
                return
            }
            let unwrappedMethod = handler.method ?? "(nil)"
            let unwrappedHost = handler.host ?? "(nil)"
            let unwrappedCaller = handler.caller ?? "(nil)"
            print("Server received request to " + unwrappedHost
                + " calling " + unwrappedMethod
                + " from " + unwrappedCaller
                + " with metadata " + handler.requestMetadata.dictionaryRepresentation.description)

            do {
                do {
                    try me.provider.provide(handler)
                } catch is HandleMethodError {
                    print("ServiceServer call to unknown method '\(unwrappedMethod)'")
                    // The method is not implemented by the service - send a status saying so.
                    try handler.call.perform(OperationGroup(
                        call: handler.call,
                        operations: [
                            .sendInitialMetadata(Metadata()),
                            .receiveCloseOnServer,
                            .sendStatusFromServer(.unimplemented, "unknown method " + unwrappedMethod, Metadata())
                    ]) { _ in
                        handler.shutdown()
                    })
                }
            } catch {
                // The individual sessions' `run` methods (which are called by `self.handleMethod`) only throw errors if
                // they encountered an error that has not also been "seen" by the actual request handler implementation.
                // Therefore, this error is "really unexpected" and  should be logged here - there's nowhere else to log it otherwise.
                print("ServiceServer unexpected error handling method '\(unwrappedMethod)': \(error)")
                do {
                    try handler.sendStatus((error as? ServerStatus) ?? .processingError)
                } catch {
                    print("ServiceServer unexpected error handling method '\(unwrappedMethod)'; sending status failed as well: \(error)")
                    handler.shutdown()
                }
            }
        }
    }
}

public protocol Provider {
    func provide(_ handler: Handler) throws
}
