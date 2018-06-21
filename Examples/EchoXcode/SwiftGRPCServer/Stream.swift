//
//  Stream.swift
//  SwiftGRPCServer
//
//  Created by Kyohei Ito on 2018/06/16.
//  Copyright © 2018年 Google. All rights reserved.
//

import Foundation
import SwiftGRPC

public protocol Streaming: class {
    associatedtype Responder: SwiftGRPCServer.Responder

    var responder: Responder { get }
    var handler: Handler { get }
    var initialMetadata: Metadata { get set }

    func cancel()
    func sendError(_ error: Error)

    func sendInitialMetadataAndWait() throws
    func receiveRequestAndWait() throws -> Data
}

public extension Streaming {
    func cancel() {
        handler.call.cancel()
        handler.shutdown()
    }

    func sendError(_ error: Error) {
        do {
            try handler.sendStatus((error as? ServerStatus) ?? .processingError)
        } catch {
            handler.shutdown()
        }
    }
}

public final class Stream<R: Responder>: ServerSessionBase, UnaryStreaming, ServerStreaming, ClientStreaming, BidirectionalStreaming {
    public typealias SentType = R.OutputType
    public typealias ReceivedType = R.InputType
    public typealias Responder = R

    public let responder: Responder

    public init(responder: R, handler: Handler) {
        self.responder = responder
        super.init(handler: handler)
    }
}
