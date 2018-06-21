//
//  ClientStreaming.swift
//  SwiftGRPCServer
//
//  Created by Kyohei Ito on 2018/06/16.
//  Copyright © 2018年 Google. All rights reserved.
//

import Foundation
import SwiftGRPC

public extension StreamReceiving {
    public func receive(timeout: DispatchTime = .distantFuture) throws -> ReceivedType? {
        return try _receive(timeout: timeout)
    }
}

public protocol ClientStreaming: Streaming, StreamReceiving {}

public extension ClientStreaming where Responder: ClientResponder, Responder.InputType == ReceivedType {
    func run() {
        do {
            try sendInitialMetadataAndWait()
            guard let responseMessage = try responder.respond(stream: self) else {
                // This indicates that the provider blocks has taken responsibility for sending a response and status, so do
                // nothing.
                return
            }
            try handler.sendResponse(message: responseMessage.serializedData(), status: .ok)
        } catch {
            sendError(error)
        }
    }
}
