//
//  UnaryStreaming.swift
//  SwiftGRPCServer
//
//  Created by Kyohei Ito on 2018/06/16.
//  Copyright © 2018年 Google. All rights reserved.
//

import Foundation
import SwiftGRPC

public protocol UnaryStreaming: Streaming {}

public extension UnaryStreaming where Responder: UnaryResponder {
    func run() {
        do {
            let requestData = try receiveRequestAndWait()
            let requestMessage = try Responder.InputType(serializedData: requestData)
            let responseMessage = try responder.respond(request: requestMessage, stream: self)
            try handler.sendResponse(message: responseMessage.serializedData(), status: .ok)
        } catch {
            sendError(error)
        }
    }
}
