//
//  EchoClientRequest.swift
//  Echo
//
//  Created by Kyohei Ito on 2018/01/19.
//  Copyright © 2018年 CyberAgent, Inc. All rights reserved.
//

import Foundation
import SwiftGRPCClient

protocol Echo_EchoClientRequest {
    typealias InputType = Echo_EchoRequest
    typealias OutputType = Echo_EchoResponse
}

protocol EchoClientRequestType: Echo_EchoClientRequest, ClientStreamingRequest {}

extension EchoClientRequestType {
    var method: CallMethod {
        return EchoMethod.collect
    }
}

struct EchoClientRequest: EchoClientRequestType {
    func buildRequest(_ message: String) -> InputType {
        var request = InputType()
        request.text = message
        return request
    }
}
