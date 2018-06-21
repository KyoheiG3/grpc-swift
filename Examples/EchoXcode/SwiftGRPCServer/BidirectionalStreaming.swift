//
//  BidirectionalStreaming.swift
//  SwiftGRPCServer
//
//  Created by Kyohei Ito on 2018/06/21.
//  Copyright © 2018年 Google. All rights reserved.
//

import Foundation
import SwiftGRPC

public protocol BidirectionalStreaming: Streaming, StreamReceiving, StreamSending {}

public extension BidirectionalStreaming where Responder: BidirectionalResponder, Responder.InputType == ReceivedType, Responder.OutputType == SentType {
    func run() {
        do {
            try sendInitialMetadataAndWait()
            if let status = try responder.respond(stream: self) {
                waitForSendOperationsToFinish()
                sendError(status)
            }
        } catch {
            sendError(error)
        }
    }
}
