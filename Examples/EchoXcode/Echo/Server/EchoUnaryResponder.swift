//
//  EchoUnaryResponder.swift
//  Echo
//
//  Created by Kyohei Ito on 2018/06/16.
//  Copyright © 2018年 Google. All rights reserved.
//

import SwiftGRPC
import SwiftGRPCServer

protocol Echo_EchoUnaryResponder {
    typealias InputType = Echo_EchoRequest
    typealias OutputType = Echo_EchoResponse
}

protocol EchoUnaryResponderType: Echo_EchoUnaryResponder, UnaryResponder {}

struct EchoUnaryResponder: EchoUnaryResponderType {
    func respond<S>(request: Echo_EchoRequest, stream: S) throws -> Echo_EchoResponse where S: UnaryStreaming {
        var response = Echo_EchoResponse()
        response.text = "Swift echo get: " + request.text
        return response
    }
}
