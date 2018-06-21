//
//  ServerStreaming.swift
//  SwiftGRPCServer
//
//  Created by Kyohei Ito on 2018/06/16.
//  Copyright © 2018年 Google. All rights reserved.
//

import Foundation
import SwiftGRPC

public extension StreamSending {
    public func send(_ message: SentType, timeout: DispatchTime = .distantFuture) throws {
        try _send(message, timeout: timeout)
    }
}

public protocol ServerStreaming: Streaming, StreamSending {}

public extension ServerStreaming where Responder: ServerResponder, SentType == Responder.OutputType {
    func run() {
        do {
            let requestData = try receiveRequestAndWait()
            let requestMessage = try Responder.InputType(serializedData: requestData)
            if let status = try responder.respond(request: requestMessage, stream: self) {
                waitForSendOperationsToFinish()
                sendError(status)
            }
        } catch {
            sendError(error)
        }
    }
}
